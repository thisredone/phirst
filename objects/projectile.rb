class Projectile
  include Ray::Helper
  attr_reader :sprite

  def initialize args
    @source = args[:source].pixels
    @target = args[:target]
    @sprite = Asset.skill(args[:image1])
    @sprite.pos = @source.zip([@sprite.image.width,
      @sprite.image.height]).map{|x|x.reduce(&:-)+UNIT/2}
    @sprite.dad = self
    @range ||= 500.0
    @type ||= :point
    @speed ||= 200
    @sound = Asset.sound("flame")
    @sound_hit = Asset.sound("flame_hit")
    @explosion = Asset.skill(args[:image2])
    @explosion.sheet_size = [4,4]
    @explosion.sheet_pos = [0,0]
    @explosion.dad = self
    run
  end

  def run
    @sound.play
    vector = @target.to_vector2-@source.to_vector2
    distance = Math.sqrt(vector.to_a.inject(0){|x,y|x+=y*y})
    if distance > @range
      d = @range/distance
      vector = vector.to_a.map{|x|x*d}
      distance = @range
    elsif @type == :range
      d = @range/distance
      vector = vector.to_a.map{|x|x*d}
      distance = @range
    end
    $animations << translation(
      of: vector,
      duration: distance/@speed
      ).start(@sprite)
    $map.skill self
  end
  def draw w
    w.draw @sprite
  end
  def update;end
end