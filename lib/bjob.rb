require "batch"

module BJob
  class Job
    # Process a group of items. Useful for handling transactions or pipelining.
    def batch(items)
      yield(items)
    end

    # Process a single, stand-alone item.
    def process(item)
      raise NotImplementedError
    end

    # Return items to be processed, optionally receiving a filter.
    # The result should be Enumerable.
    def items(filter = nil)
      raise NotImplementedError
    end

    def self.run(filter = nil)
      instance = new

      instance.batch(instance.items(filter)) do |items|
        if BJob.interactive?
          Batch.each(items) do |item|
            instance.process(item)
          end
        else
          items.each do |item|
            instance.process(item)
          end
        end
      end
    end
  end

  class Group
    def self.jobs
      @jobs ||= []
    end

    def self.run(filter = nil)
      jobs.each do |job|
        job.run(filter)
      end
    end
  end

  class SizedEnumerator < Enumerator
    attr :size

    def initialize(size, &block)
      @size = size
      super(&block)
    end
  end

  def self.interactive=(value)
    @interactive = value
  end

  def self.interactive?
    !! @interactive
  end

  self.interactive = false
end
