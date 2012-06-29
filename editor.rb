require 'ray'
require 'pry'
require './misc/ray_helper'
require 'yaml'

UNIT = 40
WIND0W_WIDTH = 1100
WINDOW_HEIGHT = 600

class Fixnum
  def pixels;self * UNIT;end
  def units;self / UNIT;end
  def with_zeros how_many=4, base = 10
    self.to_s(base).rjust how_many, ?0
  end
end

def color
  Ray::Color
end

class Array
  def units
    self.map{|x| (x/UNIT).to_i}
  end
  def pixels
    self.map{|x| (x*UNIT).to_i}
  end
end

class Editor < Ray::Scene
  scene_name :editor

  def setup
    @mouse_pos = [0,0]
    @mouse_spos = [0,0].to_vector2
    @rect = Ray::Polygon.rectangle([0, 0, UNIT, UNIT], Ray::Color.new(255,200,200,60))
    @view = window.default_view
    @map = Map.new
    @ui = UI.new
  end

  def register
    on :mouse_press do |button, pos|
      @ui.click(pos, button) ||
      @map.click(@mouse_pos, button)
    end
    on :key_press, key(:s) do
      @map.save
    end
  end

  def always
    @mouse_pos = (@view.center+(mouse_pos-@view.size/2))
    @rect.pos = @mouse_pos.units.pixels
    if mouse_pos.x > WIND0W_WIDTH-40
      @view.center += [5,0] if @view.center.x < $size[0].pixels-(WIND0W_WIDTH/2-50)
    elsif mouse_pos.x < 240 && mouse_pos.x > 200
      @view.center -= [5,0] if @view.center.x > 300
    end
    if mouse_pos.y > WINDOW_HEIGHT-40
      @view.center += [0,5] if @view.center.y < $size[1].pixels-(WINDOW_HEIGHT/2-50)
    elsif mouse_pos.y < 40
      @view.center -= [0,5] if @view.center.y > (WINDOW_HEIGHT/2-50)
    end
  end

  def render w
    always
    w.with_view @view do
      @map.draw w
      w.draw @rect
    end
    @ui.draw w
  end

  def clean_up
  end

end

class Map
  def initialize size = [30,30]
    $size = size
    k = Ray::Polygon.rectangle([0, 0, UNIT, UNIT], Ray::Color.new(0,0,0,255))
    k.outline_width = 1
    k.outline = Ray::Color.new(255,255,255,100)
    k.outlined = true
    @map = Array.new(size[0]).map{|x| Array.new(size[1])}.map{|x|x.map{[]}}
    @grid = Array.new(size[0]).map{|x| Array.new(size[1]) }
    0.upto(@map.size-1) do |x|
      0.upto(@map[0].size-1) do |y|
        l = k.dup
        l.pos = [x,y].pixels
        @grid[x][y] = l
      end
    end
  end
  def draw w
    @grid.each do |x|
      x.each{|o| w.draw o rescue nil}
    end
    @map.each do |x|
      x.each do |y|
        y.each do |o|
          w.draw o
        end
      end
    end
  end
  def click pos, button
    return if pos.x < 0 || pos.x > $size[0].pixels || pos.y < 0 || pos.y > $size[1].pixels
    x,y = pos.units
    s = $selected_sprite.dup
    s.pos = [x,y].pixels
    @map[x][y].delete @map[x][y].find{|x| x.image.texture==s.image.texture rescue nil }
    @map[x][y] << s
  end
  def save
    map = @map.dup
    map.each do |x|
      x.map! do |y|
        $sprites[y.last.image.texture] || "assets/ground/4.png" rescue "assets/ground/4.png"
      end
    end
    images = map.flatten.uniq.enum_for(:each_with_index).
              map{|x,i| {x => "t#{i}".to_sym} }.inject(&:merge)
    map.each{ |x| x.map!{ |y| images[y] } }
    result = {}
    images.each{ |k,v| result[v] = k }
    result[:map] = map
    File.open('map.yml','w+'){|f| f.puts result.to_yaml}
  end
end

class UI

  def initialize
    @panel = Ray::Polygon.rectangle([0,0,200,WINDOW_HEIGHT], Ray::Color.new(0,0,0,255))
    @panel.outline_width = 1
    @panel.outline = Ray::Color.new(255,255,255,100)
    @panel.outlined = true
    @arrow_up_rect = [82,170,40,20].to_rect
    @arrow_down_rect = [82,504,40,20].to_rect
    @arrow_up = Ray::Polygon.rectangle(@arrow_up_rect, Ray::Color.new(200,255,140,200))
    @arrow_down = Ray::Polygon.rectangle(@arrow_down_rect, Ray::Color.new(200,255,140,200))
    $sprites = {}
    @sprites = Dir['assets/ground/*'].map do |x|
      s = Ray::Sprite.new(Ray::Image.new(x))
      $sprites[s.image.texture] = x
      s
    end
    $selected_sprite = @sprites[23]
    @row = 0
  end

  def draw_sprites w, first_row
    @sprites[first_row*3..first_row*3+20].each_with_index do |s, i|
      s.pos = [42*(i%3)+40, 42*(i/3)+200]
      w.draw s
    end
  end

  def draw w
    w.draw @panel
    draw_sprites w, @row
    w.draw @arrow_up
    w.draw @arrow_down
  end

  def click pos, button
    return false if pos.x > 200
    s = @sprites[@row*3..@row*3+20]
    if pos.x >= s[0].pos.x && pos.x <= s[0].pos.x+126 &&
      pos.y >= s[0].pos.y && pos.y <= s[0].pos.y+294
      x = ((pos.x-40)/42).to_i
      y = ((pos.y-200)/42).to_i
      $selected_sprite = s[3*y+x] || s[-1]
    elsif @arrow_up_rect.contain? pos
      @row -= 1 if @row > 0
    elsif @arrow_down_rect.contain? pos
      @row += 1
      @row = @sprites.size/3 if @row > @sprites.size/3
    end
    true
  end

end

Ray.game "Map Editor", :size => [WIND0W_WIDTH,WINDOW_HEIGHT] do
  register { add_hook :quit, method(:exit!) }
  Editor.bind self
  scenes << :editor
end