# the queue holds events that need
# to happen in the future
# it sets and controlls timers that
# trigger specific actions

class Queue
  @@queue = []
  def self.<< arg
    @@queue << [Time.now+arg[0].to_f,arg[1]]
  end
  def self.update
    @@queue.map! do |timer,action|
      Time.now > timer ? (
        begin
          action.trigger rescue action.call
          nil
        rescue => e
          p e
          p e.backtrace.first
        end
      ) : [timer,action]
    end.compact!
  end
end