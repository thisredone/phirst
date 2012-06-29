class Tower
  include Living
  attr_accessor :pos, :kind, :id
  def initialize opts
    @pos = opts[:pos]
    @kind = opts[:kind]
    @id = ($id+=1)
    @speed = 30
    $map.add self
    Queue << [2, self]
    @hp = 1000
    @aggro_distance = 6
    @skill = '001'
  end

  def trigger
    return if dead
    aggro
    Queue << [1, self]
  end

end