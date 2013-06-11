class CostFinder
  def self.find_cost(path, data)
    path_cost = 0.0
    i = 0
    return path_cost if path.length == 0
    path.each do |node|
      next_node = path[i+1]
      cost = data[node][next_node]["total_cost"] rescue binding.pry
      begin
      path_cost += cost
      rescue
        binding.pry
      end
      break if i == (path.length - 2)
      i += 1
    end
    path_cost
  end
end
