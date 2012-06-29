module Tile

  # convinience methods for easy access
  def x;pos.x;end
  def y;pos.y;end

  def move pos, speed
    return if pos.to_vector2 == @pos
    @sprite.pos = @pos.pixels.to_vector2
    $animations.delete @move_anim if @move_anim && @move_anim.running?
    @moving = true
    speed = speed.to_i
    dir = (pos.to_vector2-@pos).to_a
    speed = dir.map(&:abs).inject(&:+)>1 ? speed*0.7 : speed
    turn dir if self.respond_to? :turn
    $animations << (@move_anim = translation(
      of: dir.pixels,
      duration: 10.0/speed
      ).start(self.sprite).type(:movement))
    @pos = pos.to_vector2
  end

  # called when any animation started with
  # self as a target ends
  def end_animation anim
    @moving = false if anim.type == :movement
  end

  def moving?;@moving;end

end