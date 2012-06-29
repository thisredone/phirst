class Player
  include Living
  @@players = []
  @@c = Counter.new
  attr_accessor :pos, :sprite, :pile, :speed, :speed_mod, :stun, :dead
  attr_reader :id
  def initialize opts
    @pile = []
    @ip = opts[:ip]
    @port = opts[:port] if opts[:kind] != 't'
    @id = ($id+=1)
    @pos = $map.spawn_point
    $map.add self
    @connection = opts[:connection]
    init_player
    puts "New player connected"
    puts "Players so far: "+(@@players.map(&:id)+[@id]).to_s
    @hp = @max_hp = 100
    @nickname = 'Nameless Soldier'
    Stats.add_player @id, @nickname
    @sprite = "amg1"
    @dead = true
    @speed = 30
    @speed_mod = 1
    @stun = nil
  end

  # sends data to a new player
  def init_player
    @connection.send_data @id.with_zeros + "_" +
      @@players.map{|p|[p.id,p.sprite,p.pos.join(".")].join(",")}.join(";")
  end

  # every player gets info about action
  # if it took place in his neighbourhood
  def self.send_out action, pos = nil
    return if !action.to_s  # to_s is custom (may be nil)
    @@players.each do |player|
      next player.send(action) if (action.class==String && pos.nil?) || 
                                  action.kind == ?x
      pos = action.pos if !pos
      delta = player.pos.zip(pos).map{|x|x.inject(&:-)}
      next if delta[0].abs > 20 or delta[1].abs > 20
      player.pile << action.to_s
    end
  end

  def self.send_pile
    @@players.each do |player|
      next if player.pile.empty?
      player.send Marshal.dump(player.pile)
      player.pile = []
    end
  end

  def self.find id
    @@players.find{|x|x.id == id}
  end

  # returns the player that matches the ID
  # or creates a new one
  def self.search opts
    @@players.find{|x|x.me? opts} ||
    (@@players << Player.new(opts))[-1]
  end

  # checks if the ID matches
  def me? opts
    @id == opts[:id].to_i && (@port ||= opts[:port]; return true)
  end

  # send data to player (self)
  def send data
    begin
      $udp.send_datagram data, @ip, @port
    rescue => e
      p e
    end
  end

  # processes data from client
  def get data
    @last_message = Time.now
    begin
      if data == 'stats'
        send Stats.to_s
        return
      elsif data[0..3] == 'nick'
        @nickname = data[4..-1]
        Stats.update @id, @nickname
        return
      elsif data[0..3] == 'init'
        marshal = Marshal.load data[4..-1]
        GamePlay.init_player self, marshal
      end
      data && alive? || return
      Player::send_out Action.new(@id,[data[0..3],data[4..7]],data[8..-1])
    rescue => e
      p e
    end
  end

  def self.timeouts
    @@players.each do |p|
      (@@players.delete p
      $map.delete p
      Stats.delete_player p.id
      )if p.timedout?
    end
  end

  def timedout?
    Time.now-@last_message > 30 && (
      puts "Player "+@id.to_s+" timed out."
      Player::send_out @id.with_zeros+"00000000c"
      true )
  end

end