class QueryPlanner
  attr_reader :plan
  # plan: an array of node types and optional predicates
  # ie:
  # [
  #   [Projection, predicate],
  #   [Selection, predicate],
  #   [Scan, filename]
  # ]
  def initialize(steps)
    child = nil
    steps.reverse.each do |node, predicate|
      nxt_child = node.new(child, predicate)
      child = nxt_child
    end
    # Set plan to point at initialized root node.
    @plan = child
  end
end

class Executor
  attr_reader :root_node, :query_result

  def initialize(root_node)
    @query_result = []
  end

  def execute
    # Just calls next on its root node until it returns nil,
    # while storing each tuple it gets
    nxt = true
    until nxt.nil?
      nxt = root_node.next
      @query_result << nxt
    end
  end
end
