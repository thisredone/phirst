class Skills::Fireball < Projectile

  def initialize args
    @range = 300.0
    @speed = 300
    @type = :point
    super args.merge({:image1 => 'flame', :image2 => 'exp'})
  end
  
  def end_animation anim
    if anim.type != :explosion
      @explosion.pos = @sprite.pos.units.pixels.zip([@explosion.image.width/4,
        @explosion.image.height/4]).map{|x|x.reduce(&:-)+UNIT}
      @sound_hit.play
      @sprite = [@explosion]
      [[0,1],[0,-1],[1,0],[-1,0]].each do |k|
        e = @explosion.dup
        e.pos += k.map{|p|p.pixels}
        @sprite << e
      end
      $animations << block_animation(:duration => 0.5,
        :block => proc { |_t, p|
          @sprite.each do |t|
            x = (p*16).round
            t.sheet_pos = [(x%4-3).abs,(x/4-3).abs] if x != 1
          end
        }).start(@explosion).type(:explosion)
    else
      $map.delete_skill self
    end
  end
  def draw w
    [*@sprite].each{|x|w.draw x}
  end
end