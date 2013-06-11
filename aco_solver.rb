require "./cost_finder.rb"
require "pry"

class AcoSolver
  def initialize(data, iterations)
    @max_it = iterations
    @num_ants = 10
    @decay = 0.1
    @c_heur = 2.5
    @c_local_phero = 0.1
    @c_greed = 0.9
    @data = data
  end

  def solve
    best = search(@data, @max_it, @num_ants, @decay, @c_heur, @c_local_phero, @c_greed)
    best[:vector].push best[:vector].first
    final_path = @data.keys.values_at *(best[:vector])
    best[:cost] = CostFinder.find_cost(final_path, @data)
    return best
  end

  def random_permutation(cities)
    perm = Array.new(cities.size){|i| i}
    perm.each_index do |i|
      r = rand(perm.size-i) + i
      perm[r], perm[i] = perm[i], perm[r]
    end
    return perm
  end

  def initialise_pheromone_matrix(num_cities, init_pher)
    m = Array.new(num_cities){|i| Array.new(num_cities, init_pher)}
    return m
  end

  def calculate_choices(nodes, last_node, exclude, pheromone, c_heur, c_hist)
    choices = []
    nodes.each_with_index do |node, i|
      next if exclude.include?(i)
      prob = {:node=>i}
      prob[:history] = pheromone[last_node][i] ** c_hist rescue binding.pry
      cost_path = nodes.values_at *[last_node, i]
      if cost_path.uniq.length == 1
        prob[:distance] = 0
      else
        prob[:distance] = CostFinder.find_cost(cost_path, @data)
      end
      prob[:heuristic] = (1.0/prob[:distance]) ** c_heur
      prob[:prob] = prob[:history] * prob[:heuristic]
      choices << prob
    end
    return choices
  end

  def prob_select(choices)
    sum = choices.inject(0.0){|sum,element| sum + element[:prob]}
    return choices[rand(choices.size)][:node] if sum == 0.0
    v = rand()
    choices.each_with_index do |choice, i|
      v -= (choice[:prob]/sum)
      return choice[:node] if v <= 0.0
    end
    return choices.last[:node]
  end

  def greedy_select(choices)
    return choices.max{|a,b| a[:node]<=>b[:prob]}[:node]
  end

  def stepwise_const(nodes, phero, c_heur, c_greed)
    perm = []
    perm << rand(nodes.length)
    begin
      choices = calculate_choices(nodes, perm.last, perm, phero, c_heur, 1.0)
      greedy = rand() <= c_greed
      next_node = (greedy) ? greedy_select(choices) : prob_select(choices)
      perm << next_node
    end until perm.size == nodes.size
    return perm
  end

  def global_update_pheromone(phero, cand, decay)
    cand[:vector].each_with_index do |x, i|
      y = (i==cand[:vector].size-1) ? cand[:vector][0] : cand[:vector][i+1]
      value = ((1.0-decay)*phero[x][y]) + (decay*(1.0/cand[:cost]))
      phero[x][y] = value
      phero[y][x] = value
    end
  end

  def local_update_pheromone(pheromone, cand, c_local_phero, init_phero)
    cand[:vector].each_with_index do |x, i|
      y = (i==cand[:vector].size-1) ? cand[:vector][0] : cand[:vector][i+1]
      value = ((1.0-c_local_phero)*pheromone[x][y])+(c_local_phero*init_phero)
      pheromone[x][y] = value
      pheromone[y][x] = value
    end
  end

  def search(data, max_it, num_ants, decay, c_heur, c_local_phero, c_greed)
    nodes = data.keys
    best = {:vector => (0..(nodes.length-1)).to_a.shuffle}
    best_cost_path = nodes.values_at *best[:vector]
    best[:cost] = CostFinder.find_cost(best_cost_path, @data)
    init_pheromone = 1.0 / (data.keys.size.to_f * best[:cost])
    pheromone = initialise_pheromone_matrix(data.keys.size, init_pheromone)
    max_it.times do |iter|
      solutions = []
      num_ants.times do
        cand = {}
        cand[:vector] = stepwise_const(data.keys, pheromone, c_heur, c_greed)
        cand_path = nodes.values_at *cand[:vector]
        cand[:cost] = CostFinder.find_cost(cand_path, data)
        best = cand if cand[:cost] < best[:cost]
        local_update_pheromone(pheromone, cand, c_local_phero, init_pheromone)
      end
      global_update_pheromone(pheromone, best, decay)
      #puts " > iteration #{(iter+1)}, best=#{best[:cost]}"
    end
    return best
  end
end
