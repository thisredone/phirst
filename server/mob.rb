class Mob
  include Living
  attr_accessor :pos, :kind, :id
  def initialize opts
    @pos = opts[:pos]
    @kind = opts[:kind]
    @id = ($id+=1)
    @speed = 30
    $map.add self
    Queue << [2, self]
    @hp = 100
    @aggro_distance = 6
    @shooting_range = 3
    @skill = '001'
  end

  def trigger
    return if dead
    aggro ||
    (self.send [:move,:chill][rand(2)])
    Queue << [1, self]
  end

  def move to = @pos.map{|x| x+=rand(3)-1}
    $map.move self, to
    Player::send_out @id.with_zeros+
                     @pos.map(&:with_zeros).join+
                     ?m+
                     @speed.with_zeros(2), @pos
  end

  def chill
    Player::send_out @id.with_zeros+
                     @pos.map(&:with_zeros).join+
                     ?m+
                     @speed.with_zeros(2), @pos
  end

end