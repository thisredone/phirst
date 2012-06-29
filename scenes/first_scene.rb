class FirstScene < Ray::Scene
  scene_name :first_scene

  def setup
    process_data
    $delta = 1
    $animations = animations
    @mouse_pos = [0,0]
    @mouse_spos = [0,0].to_vector2
    @rect = Ray::Polygon.rectangle([0, 0, UNIT, UNIT], Ray::Color.new(255,200,200,60))
    @view = window.default_view
    Stats.update
    @ui = UI.new
  end

  # creates players, map, etc.
  def process_data
    $map = Map.new
    players = $data.shift.split(";") rescue nil
    [*players].each do |p|
      p = p.split(",")
      o = Dude.new p[2].split(".").map(&:to_i), p[1]
      o.id = p[0].to_i
      $map << o
    end
  end

  def register
    on :key_press, key(:e) do
      $dude.skill :e, @mouse_pos if $dude
    end
    on :key_press, key(:q) do
      $dude.skill :q, @mouse_pos if $dude
    end
    on :key_press, key(:r) do
      $dude.skill :r, @mouse_pos if $dude
    end
    on :key_press, key(:tab) do
      Stats.switch
    end
    on :key_press, key(:+) do
      binding.pry
    end
    on :key_press, key(:escape) do
      exit!
    end
    on :mouse_press do |button, pos|
      @ui.click pos, button
    end
  end

  def always
    $client.update
    @mouse_pos = (@view.center+(mouse_pos-@view.size/2))
    @rect.pos = @mouse_pos.units.pixels
    @fps = 1.0/$delta
    if $dude
      dir = [0,0].to_vector2
      {:w => [0,-1], :s => [0,1],
        :a => [-1,0], :d => [1,0]}.each do |k,p|
        dir += p.to_vector2 if holding? k and !$dude.moving?
      end
      $dude.travel dir if dir.to_a != [0,0]
      @view.center = $dude.sprite.pos
    end
    $map.update
    @ui.update
  end

  def render w
    always
    w.with_view @view do
      $map.draw w
      w.draw @rect
    end
    Stats.draw w
    @ui.draw w
    #w.draw text @fps.to_i.to_s
    #w.draw text @mouse_pos.to_a.join(", ")
  end

  def run
    until @scene_exit
      $delta = delta{run_tick}
      t = 1.0/@scene_loops_per_second
      sleep($delta = t-$delta) if $delta < t
    end
    clean_up
  end

  def clean_up
    $dude = nil
    $map = nil
    Ray::ImageSet.clear
  end
end