module DeathMatch

  def init
    Stats.each do |k,_|
      Stats[k][:score] = 0
      Stats[k][:deaths] = 0
    end
    Player.send_out Stats.to_s
  end

  def update
    winner = Stats.find { |_,v| v[:score] >= GameConfig[:win_score] }
    self.init if winner
  end

  def init_player player, data
    Skills.new player.id
    player.sprite = data[:sprite]
    Queue << [GameConfig[:spawn_time],
      -> do
        Player::send_out Action.new(player.id, player.pos, "x#{player.sprite}")
        player.dead = false
      end
    ]
  end

  def player_died player
    player.dead = true
    Queue << [GameConfig[:spawn_time], -> { player.spawn }]
  end

end