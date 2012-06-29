class MenuScene < Ray::Scene
  scene_name :menu_scene

  def setup
    @nick = "unknown"
    @ip = "127.0.0.1"
    disable_event_group :nick_focus
    disable_event_group :ip_focus
    @nick_pos = (window.size/2-[3,96]).to_a + [100,15]
    @ip_pos = (window.size/2-[3,71]).to_a + [100,15]
    @bright = Ray::Color.new(150,150,150,255)
    @dark = Ray::Color.new(50,50,50,255)
    @white = Ray::Color.white
    @nick_rect = Ray::Polygon.rectangle(@nick_pos, @dark)
    @ip_rect = Ray::Polygon.rectangle(@ip_pos, @dark)
    @connect_button = text('CONNECT', :at => window.size/2-[6,-2],
                             :auto_center => true)
    @connect_pos = (window.size/2-[10,-4]).to_a + [70,15]
  end

  def register
    on :key_press, key(:escape) do
      exit!
    end
    event_group :nick_focus do
      on :text_entered do |char|
        l = Ray::TextHelper.convert(char)
        l != "\b" ? (@nick << l if l[/[a-zA-Z0-9 ]/]) : @nick.empty? || @nick[-1] = ""
        @nick[-1] = "" if @nick.size > 13
      end
      on :key_press, key(:tab) do
        @ip_rect.color = @bright
        @nick_rect.color = @dark
        enable_event_group(:ip_focus)
        disable_event_group(:nick_focus)
      end
    end
    event_group :ip_focus do
      on :text_entered do |char|
        l = Ray::TextHelper.convert(char)
        l != "\b" ? (@ip << l if l[/[0-9\.]/]) : @ip.empty? || @ip[-1] = ""
        @ip[-1] = "" if @ip.size > 15
      end
      on :key_press, key(:tab) do
        disable_event_group(:ip_focus)
        @ip_rect.color = @dark
        @connect_button.color = @bright
      end
    end
    on :key_press, key(:return) do
      connect
    end
    on :mouse_press do |button, pos|
      if button == :left
        pos = pos.to_a
        if in?(pos,@nick_pos[0..1],(@nick_pos[2..3].to_vector2+@nick_pos[0..1]).to_a)
          @nick_rect.color = @bright
          @ip_rect.color = @dark
          enable_event_group(:nick_focus)
          disable_event_group(:ip_focus)
          @connect_button.color = @white
        elsif in?(pos,@ip_pos[0..1],(@ip_pos[2..3].to_vector2+@ip_pos[0..1]).to_a)
          @ip_rect.color = @bright
          @nick_rect.color = @dark
          enable_event_group(:ip_focus)
          disable_event_group(:nick_focus)
          @connect_button.color = @white
        elsif in?(pos,@connect_pos[0..1],(@connect_pos[2..3].to_vector2+@connect_pos[0..1]).to_a)
          connect
        end
      end
    end
  end

  # checks if click was in a rect
  # a -> click pos
  # b -> left, upper corner
  # c -> right, lower corner
  def in? a, b, c
    a[0]>=b[0] && a[1]>=b[1] && a[0]<=c[0] && a[1]<=c[1]
  end

  def connect
    Thread.new{$id,$data = ($client = Client.new).connect @ip, @nick}
    loading
  end

  def loading
    t = Thread.new{Asset.prepare}
    while ($client && $client.state != :ready)
      @state = text $client.state.to_s
      sleep(0.015)
    end
    t.join
    push_scene :first_scene
  end
  
  def render w
    if @state
      w.draw @state
    else
      w.draw @nick_rect
      w.draw @ip_rect
      w.draw text('MENU', :at => window.size/2-[0,200],
                          :auto_center => true)
      w.draw text('NICK', :at => window.size/2-[60,100])
      w.draw text(@nick, :at => window.size/2-[0,100])
      w.draw text('IP', :at => window.size/2-[60,75])
      w.draw text(@ip, :at => window.size/2-[0,75])
      w.draw @connect_button
    end
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
    Ray::ImageSet.clear
  end
end