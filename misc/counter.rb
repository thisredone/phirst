class Counter
  def initialize;@c=0;end
  def +@;@c+=1;@c.r if @c>999;end
  def p;print("\r"+@c.to_s);end
  def r;@c=0;end
  def to_s;@c.with_zeros;end
end