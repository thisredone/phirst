class Skills
  @@skill_sets = {}
  @@skills = [:fireball, :iceball, :hammer]
  def self.[] id
    @id = id
    @@skill_sets[id]
  end

  def initialize id
    @id = id
    @@skill_sets[id] = self
    @cds = [2,2,4,5,6] # cooldowns
    @times = @cds.map{|x|Time.now-x} # last used time
    @kinds = [0,1,2,0,0] # id number of a skill
  end

  def use pos, data
    key = data[1..3].to_i
    if Time.now-@times[key] > @cds[key]
      @times[key] = Time.now
      return send(@@skills[@kinds[key]], pos, data[4..-1])
    end
    nil
  end

  def projectile pos, data, range, speed, dmg, id, area = [[0,0]]
    target = [data[0..3],data[4..7]].map{|x|x.to_i(36)}
    vector = pos.map{|x|x*UNIT}.zip(target).map{|x|x.inject(&:-)}
    distance = Math.sqrt(vector.inject(0){|x,y|x+=y*y})
    if distance > range
      d = range/distance
      distance = range
      target = [pos[0]+vector[0]*d,pos[1]+vector[1]*d]
    end
    Queue << [distance/speed, lambda do
      area.each do |delta|
        hit_spot = [target[0]/UNIT+delta[0],target[1]/UNIT+delta[1]]
        $map.hit dmg, hit_spot, @id
        yield(hit_spot) if block_given?
      end
    end]
    "s#{id.to_s.rjust(3,'0')}#{data}"
  end

  def fireball pos, data
    projectile(pos, data, 300, 300.0, 15, 0,
      [[0,0],[1,0],[-1,0],[0,1],[0,-1]])
  end

  def iceball pos, data
    projectile(pos, data, 400, 400.0, 30, 1) do |hit_spot|
      next unless target = $map.locate(hit_spot)
      s = target.speed_mod
      sm = s-0.3 < 0.2 ? 0.3-(0.2-(s-0.3)) : 0.3
      target.speed_mod -= sm
      Queue << [2, lambda do
        target.speed_mod += sm
      end]
    end
  end

  def hammer pos, data
    projectile(pos, data, 250, 450.0, 25, 2) do |hit_spot|
      next unless target = $map.locate(hit_spot)
      time = Time.now + 1.2
      target.stun = time
      Queue << [1.2, lambda do
        target.stun = nil if target.stun <= time
      end]
    end
  end

end