require 'ray'
require 'socket'
require 'yaml'
require 'timeout'
require 'pry'
require 'animation'
require 'sprite'

UNIT = 40

class Fixnum
  def pixels;self * UNIT;end
  def units;self / UNIT;end
  def with_zeros how_many=4, base = 10
    self.to_s(base).rjust how_many, ?0
  end
end

def color
  Ray::Color
end

def delta;t=Time.now;yield;Time.now-t;end

class Array
  def units
    self.map{|x| (x/UNIT).to_i}
  end
  def pixels
    self.map{|x| (x*UNIT).to_i}
  end
end

module Skills;end

require 'ray_helper'
require 'asset'
require 'game_object'
require 'counter'
require 'client'
require 'menu_scene'
require 'ui'
require 'first_scene'
require 'ground_tile'
require 'building'
require 'map'
require 'tile'
require 'dude'
require 'projectile'
Dir["skills/*"].each &method(:require)
require 'stats'