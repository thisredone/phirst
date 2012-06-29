class Stats

  @@stats = nil
  @@switch = :on

  def self.switch
    @@switch = @@switch == :on ? :off : :on
    self.update if self.on?
  end

  def self.on?;@@switch==:on end
  def self.off?;@@switch==:off end

  def self.update
    $client.send :action => :stats
  end

  def self.get packet
    @@stats = Marshal::load packet
  end

  def self.draw w
    return if self.off? || @@stats.class != Hash || @@stats.empty?
    w.draw Ray::Text.new "kills     deaths     nick", 
                         :at => [15, 25],
                         :color => Ray::Color.new(255,180,180,255)
    at = [20,40].to_vector2
    @@stats.each do |id, stats|
      w.draw Ray::Text.new stats[:score].to_s, :at => at
      w.draw Ray::Text.new stats[:deaths].to_s, :at => at+[50, 0]
      w.draw Ray::Text.new stats[:nick], :at => at+[80, 0]
      at += [0, 20]
    end
  end

end