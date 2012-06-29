Dir["./server/game_modes/*"].each(&method(:require))

class GamePlay

  class << self

    include DeathMatch

    # def init
    # end

    # def update
    # end

    # def init_player player, data
    # end

  end

end