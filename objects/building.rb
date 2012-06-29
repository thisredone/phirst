class Building < GameObject
  include Ray::Helper
  attr_accessor :sprite, :pos, :id
  def initialize file, pos
    @sprite = Ray::Sprite.new(image ("assets/buildings/"<<file))
    @sprite.pos = pos.map(&:pixels).to_vector2
  end

  def update
  end

end