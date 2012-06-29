module Living
  attr_accessor :hp, :dead
  def take_hit dmg
    @hp -= dmg
    :dead if @hp <= 0
  end

  def alive?
    !@dead
  end

  def aggro
    #(@aggro
    #  if @aggro then punch that guy instead
    #  of searching for another one
    #  first make sure he's in range
    #) ||
    # (@aggro, dist = 
    #   $map.aggro(self, @aggro_distance)) && (
    #   @shooting_range && (
    #     if dist > @shooting_range
    #       move @pos.zip(@aggro.pos.zip(@pos).
    #       map{|x|x.inject(&:<=>)}).map{|x|x.inject(&:+)}
    #       return true
    #     end
    #   )
    #   Player::send_out(Action.new @id,
    #              @pos,
    #              ?s + @skill+
    #              @aggro.pos.map(&:with_zeros).join)
    #   return true
    # )
    false # if not aggroed
  end

  # spawn
  def spawn
    @dead = false
    @pos = $map.spawn_point
    @hp = @max_hp
    Player::send_out Action.new(@id, @pos, "x#@sprite")
  end

end