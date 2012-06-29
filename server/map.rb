class Map
  MAP_SIZE = 100
  # NODE_SCALE = 20 # gotta divide
  def initialize
    @map = Array.new(MAP_SIZE).
      map{Array.new(MAP_SIZE)}.
      map{|x| x.map{[]}}
    @map[0].map!{|x|[1]}
    @map[-1].map!{|x|[1]}
    @map[1..-2].each{|x|x[0]=[1];x[-1]=[1]}
    # @nodes = Array.new(MAP_SIZE/NODE_SCALE).
    #   map{Array.new(MAP_SIZE/NODE_SCALE)}.
    #   map{|x| x.map{[]}}
  end

  def add o
    x,y = o.pos
    # @nodes[x/NODE_SCALE][y/NODE_SCALE] << o
    @map[x][y] << o
  end

  def hit dmg, t, id
    return if !(target = @map[t[0]][t[1]].first) ||
              !target.respond_to?(:alive?) || id == target.id
    puts "#{id} hit #{target.id} for #{dmg} dmg!"
    status = target.take_hit(dmg)
    Player::send_out Action.new(target.id,target.pos,'hi'+
                      target.hp.with_zeros(3,36)+
                      dmg.with_zeros(3,36))
    if status == :dead
      Player::send_out Action.new(target.id,target.pos,'d')
      Stats.score :killer => id, :victim => target
      @map[t[0]][t[1]].delete target
      # @nodes[t[0]/NODE_SCALE][t[1]/NODE_SCALE].delete target
      GamePlay.player_died target
    end
  end

  def locate t
    return if !(target = @map[t[0]][t[1]].first) ||
              !target.respond_to?(:alive?)
    target
  end

  def move o, pos
    x2,y2 = pos
    return if @map[x2][y2].any? # collission
    x,y = o.pos
    @map[x][y].delete o
    @map[x2][y2] << o
    # a = [x,y,x2,y2].map{|k|k/=NODE_SCALE}
    # (a[0]-a[2])+(a[1]-a[3]) == 0 ||
    #   (@nodes[a[0]][a[1]].delete o
    #   @nodes[a[2]][a[3]] << o)
    o.pos = pos
  end

  def delete o
    x,y = o.pos
    # @nodes[x/NODE_SCALE][y/NODE_SCALE].delete o
    @map[x][y].delete o
  end

  def aggro o, dist
    # x,y = o.pos
    # [@nodes[x/NODE_SCALE][y/NODE_SCALE],
    #   *([[x+dist,y], [x,y+dist], [x-dist,y], [x,y-dist]].map {|ex,ey|
    #     next nil if ex < 0 || ey < 0
    #     @nodes[ex/NODE_SCALE][ey/NODE_SCALE]}.compact)
    # ].uniq.flatten.each{|x|
    #   next if x == o
    #   distance = Math.sqrt(x.pos.zip(o.pos).
    #     map{|x|(p=x.inject(&:-))*p}.inject(&:+)).round
    #   return [x,distance] if distance < dist
    # }
    false
  end

  def spawn_point
    [rand(30)+3,rand(30)+3]
  end

end