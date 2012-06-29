class Stats
  @@stats = {}
  def self.score opts
    killer = opts[:killer]
    victim = opts[:victim]
    puts "killer: #{killer}, victim: #{victim.id}"
    @@stats[killer].nil? || @@stats[killer][:score] += 1
    @@stats[victim.id].nil? || @@stats[victim.id][:deaths] += 1
  end

  def self.to_s
    '.'<<Marshal::dump(@@stats)
  end

  def self.add_player id, nick
    @@stats[id] || @@stats[id] = {:score => 0, :deaths => 0, :nick => nick}
  end

  def self.delete_player id
    @@stats.delete id
  end

  def self.update id, nick
    @@stats[id] && @@stats[id][:nick] = nick
  end

  def self.method_missing n, *args, &block
    @@stats.send n, *args, &block
  end

end