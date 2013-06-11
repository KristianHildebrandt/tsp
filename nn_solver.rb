require "./cost_finder.rb"

class NNSolver
  def self.solve(data)
    nodes = data.keys
    start_node = nodes.delete(nodes.first)

    path = []
    current_node = start_node
    path.push current_node

    while nodes.length > 0
      shortest_node = {cost: 1}
      nodes.each do |dest_node|
        d_node = data[current_node][dest_node]
        cost_to_node = d_node["total_cost"]
        if cost_to_node < shortest_node[:cost]
          shortest_node[:cost] = cost_to_node
          shortest_node[:node] = dest_node
        end
      end
      current_node = shortest_node[:node]
      nodes.delete(current_node)
      path.push current_node
    end

    path.push start_node
    cost = CostFinder.find_cost(path, data)
    res =  {cost: cost, result_path: path}
    res
  end
end
