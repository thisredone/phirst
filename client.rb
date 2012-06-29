class Client

  attr_accessor :state

  def initialize
    @id = '0000'
    @ack = Counter.new
    @last_send = Time.now
    @last_move = Time.now
    Thread.new do
      sleep 0.5 # may need to add some here
      loop do
        receive
      end
    end
  end

  def connect ip, nick
    @state = :estabilishing_connection
    begin
      (@udp = UDPSocket.new).connect ip, 8800
      (@tcp = TCPSocket.open(ip, 8801)).send "t...nick#{nick}", 0
      @state = :connected
      data = @tcp.recvfrom(3000)[0]
      data = data.split("_")
      @id = data.shift
      @udp.send @id+"00000000u",0
    rescue => e
      p e
      p e.backtrace
    end
    @state = :ready
    [@id.to_i,data]
  end

  def send opts
    packet = case opts[:action]
      when "m" # movement
        Time.now-@last_move < 0.1 ? nil : (
        @last_move = Time.now
        @id+
        opts[:pos].to_a.map{|x|x.to_i.with_zeros(4,36)}.
        join<<'m'<<opts[:speed].with_zeros(2))
      when "s" # skill
        @id+
        opts[:pos].to_a.map{|x|x.to_i.with_zeros(4,36)}.join<<
        's'<<opts[:skill]<<
        opts[:target].to_a.map{|x|x.to_i.with_zeros(4,36)}.join
      when :stats
        @id + 'stats'
      when :init
        @id + 'init' + opts[:data]
      else return
      end
    @last_send = Time.now
    @udp.send packet, 0 if packet
    #@udp.send packet, 0 if opts[:action] == "m"
  end

  def update
    if Time.now-@last_send > 5
      @udp.send @id+"00000000u",0 rescue puts("asdf")
      @last_send=Time.now
    end
  end

  def receive
    begin
      r = if select([@udp], nil, nil)
        @udp.recvfrom(65536)
      end
      r && (
        if r[0][0] == "\x04"
          Marshal.load(r[0]).each{|x|process x}
        else
          process(r[0])
        end
      )
    rescue => e
      p e
      p e.backtrace
    end
  end

  # p -> packet
  def process p
    if @state != :ready
      @state = :downloading_data
      return
    end
    if p[0] == '.' # stats
      Stats.get p[1..-1]
      return
    end
    id = p[0..3].to_i
    pos = [p[4..7],p[8..11]].map{|x|x.to_i 36}
    action = p[12]
    begin
      case action
      when ?m # movement
        speed = p[13..14]
        ($map.search(id) ||
        (o = Dude.new pos
        o.id = id
        $map.add o
        )).move(pos,speed)
      when ?s # skill
        skill = p[13..15].to_i
        target = [p[16..19],p[20..23]].map{|x|x.to_i(36)}
        Skills::Fireball.new \
          source: pos,
          target: target if skill == 0
        Skills::Iceball.new \
          source: pos,
          target: target if skill == 1
        Skills::Hammer.new \
          source: pos,
          target: target if skill == 2
      when ?c # disconnected
        $map.delete $map.search(id)
        puts "Player "+id.to_s+" disconnected"
        Stats.update
      when ?d # dead
        $map.search(id).die
        Stats.update
      when ?h # health change. hIt or hEal
        dmg, hp = p[17..19].to_i(36), p[14..16].to_i(36)
        if p[13] == ?i # hit
          $map.search(id).take_hit dmg, hp rescue nil
        else # heal
          $map.search(id).heal dmg, hp rescue nil
        end
      when ?x # player spawn
        sprite = p[13..16]
        ($map.search(id) ||
        (o = Dude.new pos, p[13..-1]
        o.id = id
        if id == $id
          $dude = o
          $dude.id = $id
        end
        $map.add o
        )).spawn pos, sprite
      end
    rescue => e
      p e
      binding.pry
      p e.backtrace
    end
  end

end