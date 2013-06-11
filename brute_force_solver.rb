require "./cost_finder.rb"

class BruteForceSolver
  def self.solve(data)
    nodes = data.keys
    start_node = nodes.delete(nodes.first)
    permutations = nodes.permutation.to_a
    smallest_cost = 1
    best_p = nil
    permutations.each do |permutation|
      permutation.push start_node
      permutation.unshift start_node
      cost = CostFinder.find_cost(permutation, data)
      best_p = permutation
      smallest_cost = cost if cost < smallest_cost
    end
    return {cost: smallest_cost, path: best_p}
  end
end
