class Asset
  @@assets = {:guys => {}, :skills => {}, :gui => {}, :guys_preview => [], :sounds => {}}
  def self.prepare
    location="assets/guys/"
    %w{amg1 amg2 amg3 amg4 avt1 avt2 avt3 avt4 bmg1 bmg2 bmg3 
    bmg4 chr1 dvl1 ftr1 ftr2 ftr3 ftr4 gsd1 isd1 jli1 kin1 knt1 
    knt2 knt3 knt4 man1 man2 man3 man4 mnt1 mnt2 mnt3 mnt4 mnv1 
    mnv2 mnv3 mnv4 mst1 mst2 mst3 mst4 nja1 nja2 nja3 nja4 npc1 
    npc2 npc3 npc4 npc5 npc6 npc7 npc8 npc9 pdn1 pdn2 pdn3 pdn4 
    scr1 scr2 scr3 scr4 skl1 smr1 smr2 smr3 smr4 spd1 syb1 thf1 
    thf2 thf3 thf4 trk1 wmg1 wmg2 wmg3 wmg4 wmn1 wmn2 wmn3 wnv1 
    wnv2 wnv3 wnv4 ybo1 ygr1 zph1}.each do |name|
      @@assets[:guys][name] = %w{bk fr lf rt}.map do |dir|
        ['1.gif','2.gif'].map do |n|
          Ray::Image.new(location+name+"_"+dir+n)
        end
      end
    end
    @@assets[:guys_preview] = @@assets[:guys].map do |name,dude|
      [name,Ray::Sprite.new(dude[1][0])]
    end
    %w{flame flame_stone flame_snow exp exp_stone exp_snow}.each do |skill|
      @@assets[:skills][skill] = Ray::Image.new("assets/skills/#{skill}.png")
    end
    %w{flame flame_hit}.each do |sound|
      @@assets[:sounds][sound] = Ray::Sound.new("assets/sound/#{sound}.wav")
    end
  end

  def self.dude name
    @@assets[:guys][name]
  end

  def self.guys_preview
    @@assets[:guys_preview]
  end

  def self.skill name
    Ray::Sprite.new @@assets[:skills][name]
  end

  def self.sound name
    @@assets[:sounds][name]
  end

  def self.gui name
    Ray::Image.new "assets/gui/#{name}.png"
  end

  def self.miniature name
    Ray::Image.new "assets/miniatures/#{name}.png"
  end

end