require "./cost_finder.rb"

class KOptSolver
  def self.solve(data, opt, biased_path = false)
    if biased_path
      biased_path.delete(biased_path.last)
      nodes = biased_path
    else
      nodes = data.keys
    end

    #remove the start_node from the array, will be added at the end and start later
    start_node = nodes.delete(nodes.first)
    nodes.shuffle! unless biased_path # randomize order of destinations => initial tour
    grouped_nodes = nodes.each_slice(opt).to_a

    # start and end point stay the same
    initial_path = nodes.dup
    initial_path.push start_node
    initial_path.unshift start_node

    # get the cost of the initial path
    best_cost = CostFinder.find_cost(initial_path, data)
    coppied_nodes = grouped_nodes.dup

    grouped_nodes.each do |group|
      possible_combinations = group.permutation.to_a.select{|n| n != group}
      possible_combinations.each do |com|
        index = coppied_nodes.index(group)
        new_nodes = coppied_nodes.dup
        new_nodes[index] = com
        new_path = new_nodes.flatten
        new_path.push start_node
        new_path.unshift start_node
        cost = CostFinder.find_cost(new_path, data)
        if cost < best_cost
          best_cost = cost
          grouped_nodes[index] = com
        end
      end
    end
    best_cost
  end
end
