require 'csv'

class Node; end

# Yields a single record from "disk" each time next()
# is called. Does not have child node.
# Note: When this becomes FileScan, it will need to read
# exactly 4k blocks at a time.
class Scan < Node
  attr_reader :filename

  def initialize(child = nil, filename)
    csv_text = File.read(filename)
    @data = CSV.parse(csv_text, headers: true)
    @idx = 0
  end

  def next
    return nil if idx >= data.length
    @idx += 1
    data[idx - 1]
  end
end

# Initialized with a predicate fn, yields next record
# for which predicate == true.
class Selection < Node
  attr_reader :predicate

  # Takes a predicate as a Proc
  def initialize(child, predicate)
    @predicate = predicate
  end

  def next
    nxt = child.next
    return nil if nxt.nil?
    if predicate.call(nxt)
      nxt
    else
      self.next
    end
  end
end

# Takes a predicate which is essentially an instruction for which columns
# to return and if they need to be modified.
class Projection < Node
  attr_reader :predicate

  def initialize(child, predicate)
    @predicate = predicate
  end

  def next
    predicate.call(child.next)
  end
end

class Sort < Node
  attr_reader :result, :sorted_result
  attr_reader :finished
  attr_reader :idx

  def initialize
    @finished = false
    @idx = 0
    @result = []
    @sorted_result = []
  end

  def next
    if finished
      @idx += 1
      sorted_results[idx - 1]
    else
      # Call next on child until we have everything, then set finished
      # flag, then return one
    if child.next.nil?
      sort_results
    else

  end

end

class Distinct < Node
end

# # Test scan:
# node = Scan.new('ml-20m/movies.csv')
# 10.times { puts node.next }
#
# # Test selection:
# predicate = Proc.new { |row| row[0].to_i % 2 == 0 }
# node = Selection.new('ml-20m/movies.csv', predicate)
# 10.times { puts node.next }
