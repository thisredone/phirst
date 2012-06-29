class Skills::Hammer < Projectile

  def initialize args
    @range = 250.0 # FLOAT !
    @speed = 450
    @type = :point
    super args.merge({:image1 => 'flame_stone', :image2 => 'exp_stone'})
  end
  
  def end_animation anim
    if anim.type != :explosion
      @explosion.pos = @sprite.pos.units.pixels.zip([@explosion.image.width/4,
        @explosion.image.height/4]).map{|x|x.reduce(&:-)+UNIT}
      @sound_hit.play
      @sprite = @explosion
      $animations << block_animation(:duration => 0.5,
        :block => proc { |t, p|
          x = (p*16).round
          t.sheet_pos = [(x%4-3).abs,(x/4-3).abs] if x != 1
        }).start(@explosion).type(:explosion)
    else
      $map.delete_skill self
    end
  end
end