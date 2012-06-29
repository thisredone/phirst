class GameConfig
  @@config = {}

  def self.init opts = {}
    @@config[:spawn_time] = 1
    @@config[:win_score] = 3
  end

  def self.method_missing n, *args, &block
    @@config.send n, *args, &block
  end

end