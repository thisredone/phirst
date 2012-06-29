require 'eventmachine'
require 'pry'
$: << 'server'

UNIT = 40
class Fixnum
  def with_zeros how_many=4, base = 10
    self.to_s(base).rjust how_many, ?0
  end
end

class Counter
  def initialize;@c=0;end
  def +@;@c+=1;end
  def p;print("\r"+@c.to_s);end
  def r;@c=1;end
end

%w{game_config game_play stats map skills living player queue 
action mob tower}.each{|x|require x}

module Handler
  @@c = Counter.new
  def post_init
  end

  def receive_data data
    #+@@c
    #@@c.p
    peer = get_peername[2,6].unpack("nC4")
    (Player.search :ip => peer[1..-1].join("."),
                  :port => peer[0],
                  :id => data[0..3],
                  :connection => self,
                  :kind => data[0]).get data[4..-1]
  end

end

EM.run do
  GameConfig.init
  GamePlay.init
  $id = 0
  $map = Map.new
  $udp = EM.open_datagram_socket '0.0.0.0', 8800, Handler
  EM.start_server '0.0.0.0', 8801, Handler
  EventMachine::PeriodicTimer.new(2){Player.timeouts}
  EventMachine::PeriodicTimer.new(0.02){Queue.update}
  EventMachine::PeriodicTimer.new(0.02){Player.send_pile}
  EventMachine::PeriodicTimer.new(0.05){GamePlay.update}
  puts 'Serwer started'
end