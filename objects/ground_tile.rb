class GroundTile
  include Ray::Helper
  attr_accessor :sprite, :pos
  def initialize file,x,y
    @ground_type = file.match(/\/(\w+)\./)[1]
    @sprite = Ray::Sprite.new(image (file))
    @sprite.pos = [x,y].map(&:pixels).to_vector2
  end
end