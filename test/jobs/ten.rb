require_relative "../../lib/bjob"
require "fileutils"

class Ten < BJob::Job
  def initialize
    @path = File.expand_path("../tmp/ten", File.dirname(__FILE__))
  end

  def batch(items)
    FileUtils.mkdir_p(@path)

    yield(items)
  end

  def process(item)
    File.write(File.join(@path, "#{item}.txt"), (item % 2).to_s)
  end

  def items(filter = nil)
    (0..9).to_a
  end
end
