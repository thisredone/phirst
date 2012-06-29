class Action
  attr_accessor :pos, :kind, :id

  def initialize id, pos, rest
    @id = id
    @pos = pos[0].class == String ? pos.map{|x|x.to_i(36)} : pos
    @rest = rest
    begin
      case (@kind = rest[0])
        when ?m then move
        when ?s then skill
        when ?d then dead
        when ?h then hp
        when ?x then spawn
      end
    rescue => e
      puts e
      puts e.backtrace.first
    end
  end

  def to_s;@packet;end

  def prepare_packet
    @packet = @id.with_zeros+@pos.
      map{|x|x.with_zeros(4,36)}.join+@rest
  end

  def spawn;prepare_packet end
  def hp;prepare_packet end
  def dead;prepare_packet end

  def move
    p = Player.find(@id)
    return if p.stun
    $map.move(p, @pos) && (
      @packet = @id.with_zeros+@pos.
      map{|x|x.with_zeros(4,36)}.join+"m#{p.speed*p.speed_mod}"
    )
  end

  def skill
    @rest = Skills[@id].use @pos, @rest
    @rest ? prepare_packet : @packet = nil
  end

end