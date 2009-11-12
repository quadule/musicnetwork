require "thread"
require "fastthread"
 
class ThreadPool
  class Executor
    attr_reader :active
    
    def initialize(queue, mutex)
      @thread = Thread.new do
        loop do
          mutex.synchronize { @tuple = queue.shift }
          if @tuple
            args, block = @tuple
            @active = true
            begin
              block.call(*args)
            rescue Exception => ex
              $stderr.puts "#{ex.backtrace}: #{ex.message} (#{ex.class})"
            end
            block.complete = true
          else
            @active = false
            sleep 0.01
          end
        end
      end
    end
    
    def close
      @thread.exit
    end
  end
  
  attr_accessor :queue_limit
  
  # Initialize with number of threads to run
  def initialize(count, queue_limit = 0)
    @mutex = Mutex.new
    @executors = []
    @queue = []
    @queue_limit = queue_limit
    @count = count
    count.times { @executors << Executor.new(@queue, @mutex) }
  end
  
  # Runs the block at some time in the near future
  def execute(*args, &block)
    init_completable(block)
    
    if @queue_limit > 0
      sleep 0.01 until @queue.size < @queue_limit
    end
      
    @mutex.synchronize do
      @queue << [args, block]
    end
  end
  
  # Runs the block at some time in the near future, and blocks until complete
  def synchronous_execute(*args, &block)
    execute(*args, &block)
    sleep 0.01 until block.complete?
  end
  
  # Size of the task queue
  def waiting
    @queue.size
  end
    
  # Size of the thread pool
  def size
    @count
  end
  
  # Kills all threads
  def close
    @executors.each {|e| e.close }
  end
  
  # Sleeps and blocks until the task queue is finished executing
  def join
    sleep 0.01 until @queue.empty? && @executors.all?{|e| !e.active}
  end
  
protected
  def init_completable(block)
    block.extend(Completable)
    block.complete = false
  end
  
  module Completable
    def complete=(val)
      @complete = val
    end
    
    def complete?
      !!@complete
    end
  end
end