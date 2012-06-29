module Ray
  module Helper
    def is_ground?
      !!@ground_type
    end
  end
  class Vector2
    def units
      self.to_a.map(&:to_i).map(&:units)
    end
    def pixels
      self.to_a.map(&:to_i).map(&:pixels)
    end
  end
  class AnimationList
    def delete anim
      @animations.delete anim
    end
  end
end