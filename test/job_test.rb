require_relative "prelude"

setup do
  $index = []
end

class Indexer < BJob::Job
  def process(item)
    $index << item
  end

  def items(filter = nil)
    if filter
      [filter.fetch(:n)]
    else
      (1..5).to_a
    end
  end
end

scope do
  test "process everything" do
    Indexer.run

    assert_equal [1, 2, 3, 4, 5], $index
  end

  test "process some items" do
    Indexer.run(n: 2)

    assert_equal [2], $index
  end
end

class Syncer < BJob::Group
  class Cleaner < BJob::Job
    def items(filter)
      [$index]
    end

    def process(item)
      item.delete_if(&:even?)
    end
  end

  jobs << Indexer
  jobs << Cleaner
end

scope do
  test "process group" do
    Syncer.run

    assert_equal [1, 3, 5], $index
  end
end
