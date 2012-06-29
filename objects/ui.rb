class UI

  def initialize
    @@parts = []
    @@parts << Bottom.new([0,h-75,445,h])
    @@parts << SelectionScreen.new([5,50,600,500])
    @@parts << SubmitButton.new([50,250,70,20])
  end
  def w; WINDIW_WIDTH  end
  def h; WINDOW_HEIGHT end
  def wh; [WINDOW_WIDTH,WINDOW_HEIGHT].to_vector2 end

  def draw(w);@@parts.each{|x|x.draw w};end
  def update;@@parts.each{|x|x.update};end
  def click(pos, button);@@parts.each{|e|e.click pos if e.rect.contain? pos};end
  def self.pack_data
    Marshal.dump @@parts.map(&:data).compact.reduce(&:merge)
  end
  def self.submit
    $client.send :action => :init, :data => UI.pack_data
    @@parts.delete_if{|x| x.type == :selection}
  end

  class Element
    attr_reader :rect, :type
    def initialize(r);@rect=r.to_rect;setup;end
    def draw(w);end; def setup;end; def update;end
    def click(p);puts "clicked #{self.class}";end
    def data;nil;end
  end

  class Bottom < Element
    def setup
      @bg = Ray::Sprite.new Asset.gui "bottom"
      @bg.pos = [0, WINDOW_HEIGHT-@bg.image.height]
      @hp = Ray::Polygon.rectangle([0, 0, 256, 12], Ray::Color.red)
      @hp.pos = [150,WINDOW_HEIGHT-70]
      @skills = %w{i01 i02 i03}.map{ |x| Ray::Sprite.new Asset.miniature x }
      @skills.each_with_index do |skill, index|
        skill.pos = [159 + index*41, WINDOW_HEIGHT-36]
      end
      @bindings = %w{Q E R}.map{ |b| Ray::Helper.text b }
      @bindings.each_with_index do |b, index|
        b.pos = [160 + index*41, WINDOW_HEIGHT-40]
      end
      @hp_info = Ray::Helper.text "", :at => [256, WINDOW_HEIGHT-75]
    end
    def draw(w)
      [@hp, *@skills, @bg, *@bindings, @hp_info].each{|x|w.draw x}
    end
    def update
      @hp.scale_x = $dude.hp_bar.scale_x rescue nil
      @hp_info.string = "#{$dude.hp}/#{$dude.max_hp}" if $dude
    end
  end

  class SelectionScreen < Element
    def setup
      @type = :selection
      @bg = Ray::Polygon.rectangle(@rect,Ray::Color.new(200,200,150,0))
      @slots_border = Ray::Sprite.new Asset.gui 'slots_border'
      @slots_border.pos = [50,100]
      @slots = (0..5).to_a.map do |num|
        x = Ray::Sprite.new Asset.gui 'slot'
        x.pos = [59+(num/2)*38, 109+(num%2)*38];x
      end
      @slot_selected = Ray::Sprite.new Asset.gui 'slot_selected'
      @slot_selected.pos = @slots.first.pos
      @arrow_left = Ray::Sprite.new Asset.gui 'arrow_left'
      @arrow_left.pos = [15,130]
      @arrow_right = Ray::Sprite.new Asset.gui 'arrow_right'
      @arrow_right.pos = [188, 130]
      @guys_preview = Asset.guys_preview
      @showing = 0
      show_guys
      @selected = @guys[0][0]
    end
    def draw(w)
      ([@bg, @slots_border, @arrow_left, @arrow_right]+
        @slots+[@slot_selected]+@guys.map{|x|x[1] if x}.compact).each{|x|w.draw x}
    end
    def click(pos)
      @slots.each_with_index do |s,i|
        if s.rect.contain?(pos)
          @slot_selected.pos=s.pos
          @selected = @guys[i][0] rescue @guys_preview[0][0]
          return
        end
      end
      if @arrow_left.rect.contain?(pos)
        @showing -= 6
        @showing = 0 if @showing < 0
        show_guys
      elsif @arrow_right.rect.contain?(pos)
        a = @showing + 6
        a < @guys_preview.size && @showing += 6
        show_guys
      end
    end
    def show_guys
      @guys = (@showing..@showing+5).to_a.map do |num|
        x = @guys_preview[num][1] rescue (next nil)
        x.pos = [65+((num-@showing)/2)*38, 115+(num%2)*38]
        [@guys_preview[num][0],x]
      end
    end
    def data
      {:sprite => @selected}
    end
  end

  class SubmitButton < Element
    def setup
      @type = :selection
      @bg = Ray::Polygon.rectangle(@rect,Ray::Color.new(20,70,50,150))
      @bg.outline_width = 1
      @bg.outline = Ray::Color.new(150,150,150)
      @bg.outlined = true
      @text = Ray::Helper.text "SUBMIT", :at => @rect.top_left+[10,0]
    end
    def draw(w)
      w.draw @bg
      w.draw @text
    end
    def click(pos)
      UI.submit
    end
  end

end