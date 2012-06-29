class Map

  def initialize file="map"
    @map = Array.new(100)
    @map.map!{|x| x = Array.new(100)}
    @map.map!{|x| x.map!{|y| y =[]}}
    load file
    # @map_pic -> joined map tiles
    # @entities -> movable/with colision/..
    @objects = []
    @skills = []
    #@objects << Building.new("nex.png", [10,10])
  end

  def load file
    map = YAML.load_file "assets/maps/#{file}.yml"
    size_x = map[:map].size
    size_y = map[:map][0].size
    0.upto(size_x-1) do |x|
      0.upto(size_y-1) do |y|
        t = GroundTile.new(map[map[:map][x][y]],x,y)
        @map[x][y].unshift t
      end
    end
  end

  #czas 1 -> 0.015625
  def draw w
    objects = []
    @map.each do |row|
      row.each do |tiles|
        tiles.each do |tile|
          next if !tile
          tile.is_ground? && w.draw(tile.sprite)
        end
      end
    end
    @skills.each do |x|
      x.draw w
    end
    @objects.each do |obj|
      w.draw obj.sprite
      if obj.class == Dude
        w.draw obj.hp_bar
        w.draw obj.hp_bar_outline
      end
    end
  end

  def skill o
    @skills << o
    o
  end

  def delete_skill o
    @skills.delete o
  end

  def add object
    @objects << object
    object
  end
  alias :<< :add

  def update
    @objects.each &:update
  end

  def search id
    @objects.find{|x| x.id == id}
  end

  def delete o
    @objects.delete o
  end

end