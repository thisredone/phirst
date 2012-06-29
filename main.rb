%w{. objects scenes misc modules assets}.each{|x|$:<<x}
require 'helper'

WINDIW_WIDTH = 800
WINDOW_HEIGHT = 600

Ray.game "game", :size => [WINDIW_WIDTH,WINDOW_HEIGHT] do
  register{add_hook :quit, method(:exit!)}
  FirstScene.bind self
  MenuScene.bind self
  scenes << :menu_scene
end