class Dude < GameObject
  include Ray::Helper
  include Tile
  attr_reader :sprite, :hp, :max_hp
  attr_accessor :speed, :pos, :hp_bar, :hp_bar_outline

  # pos resembles position of the character in a tile-based units
  # sprites pos keeps the actual position on the screen
  # cur_img is the direction the sprite is looking
  # cur_anim is the frame of the animation 
  def initialize pos=[3,3], name="amg1"
    @images= Asset.dude name
    @cur_img= 1
    @cur_anim= 0
    @sprite= Ray::Sprite.new @images[1][0]
    @sprite.dad = self
    @pos= pos.to_vector2
    @sprite.pos = pos.pixels.to_vector2
    @speed= 30
    @step= 0.0
    @moving = false
    $map << self
    @hp = @max_hp = 100
    @hp_bar = Ray::Polygon.rectangle([0,0,38,3], Ray::Color.red)
    @hp_bar_outline = Ray::Polygon.rectangle([0,0,38,3], Ray::Color.new(0,0,0,0))
    @hp_bar_outline.outline_width = 1
    @hp_bar_outline.outline = Ray::Color.black
    @hp_bar_outline.outlined = true
    Stats.update if $client
  end

  # changes the direction in which the sprite
  # is looking
  def turn dir
    dir[1]==0?(dir[0]>0?switch(3):switch(2)):(dir[1]>0?switch(1):switch(0))
  end

  # switches the sprite image to perform
  # animation or direction change
  def switch i,j=@cur_anim
    @cur_img= i
    @sprite.image= @images[i][j]
  end

  # goes from 0.0 to > 1.0 and when it does
  # it switches the sprite's frame and zeroes
  # the @step variable
  def anim
    @step += @speed*$delta*0.1
    if @step >= 1
      @cur_anim= @cur_anim==0 ? 1 : 0
      switch @cur_img, @cur_anim
      @step= 0.0
    end
  end

  # called every tick by the scene
  def update
    @hp_bar_outline.pos = @hp_bar.pos = @sprite.pos + [1,36].to_vector2
    anim if @moving
  end

  # does skills
  # serwer needs to take care of the skills
  # especially cooldown and if that skill is even there
  def skill key, target
    key = [:q,:e,:r].index(key).to_s.rjust(3,'0')
    $client.send action: ?s,
                 pos: @pos,
                 skill: key,
                 target: target
  end

  # sends movement request to server
  def travel dir
    $client.send action: ?m,
                 pos: @pos+dir.to_vector2,
                 speed: @speed
  end

  def take_hit dmg, hp
    @hp = hp
    @hp_bar.scale_x = @hp.to_f/@max_hp
  end

  def heal dmg, hp
    @hp = hp
    @hp_bar.scale_x = @hp.to_f/@max_hp
  end

  def die
    @hp_bar.scale_x = 0
    # change sprite to something
    # maybe add some sound effect!
  end

  def spawn pos, sprite_name='amg1'
    # chamge the sprite back to the original
    # add some particles or some shit
    # and a sound effect!
    @images = Asset.dude sprite_name
    @sprite = Ray::Sprite.new @images[1][0]
    @sprite.dad = self
    @pos = pos.to_vector2
    @sprite.pos = @pos.pixels.to_vector2
    @hp = @max_hp
    @hp_bar.scale_x = 1
  end

end