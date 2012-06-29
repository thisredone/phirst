module Ray
  class Animation
    def end_animation
      if target.class == Sprite and target.dad
        target.dad.end_animation self if target.dad.respond_to? :end_animation
      end
    end
    def type arg=nil
      arg ? (@type=arg;self) : @type
    end
  end
end