require 'rubygems'
require 'bundler/setup'
require "colored"
require "active_support/json"
require "terminal-table"
require "./lib/brute_force_solver.rb"
require "./lib/nn_solver.rb"
require "./lib/k_opt_solver.rb"
require "./lib/aco_solver.rb"

data_files_small = ["data/5_nodes.json", "data/5_nodes_spread.json", "data/10_nodes.json", "data/10_nodes_spread.json"]
data_files_big = ["data/20_nodes.json", "data/20_nodes_spread.json" ,"data/50_nodes.json", "data/50_nodes_spread.json","data/100_nodes.json"]

data_files_small.each do |file|
  data = JSON.parse(File.read(file))

  puts "File: #{file}".cyan
  # brute force
  exact = BruteForceSolver.solve(data)
  exact_result = exact[:cost]
  puts "Exact result: #{exact_result.to_s}".blue

  ##nearest_neighbot
  nn_result = NNSolver.solve(data)
  puts "Nearest Neighbor result: " + nn_result[:cost].to_s
  puts "difference: #{((nn_result[:cost]-exact_result)/exact_result).round(4)*100}%\n\n"

  ##2-opt
  k2_result = KOptSolver.solve(data,2)
  puts "2-opt result: " + k2_result.to_s
  puts "difference: #{((k2_result-exact_result)/exact_result).round(4)*100}%\n\n"

  ##3-opt
  k3_result = KOptSolver.solve(data,3)
  puts "3-opt result: " + k3_result.to_s
  puts "difference: #{((k3_result-exact_result)/exact_result).round(4)*100}%\n\n"

  #Ant Colony
  aco = AcoSolver.new(data, 100)
  aco_result = aco.solve
  aco_cost = aco_result[:cost]
  puts "aco result: " + aco_cost.to_s
  puts "difference: #{((aco_cost-exact_result)/exact_result).round(4)*100}%\n\n"
end

puts "------------------------------------------------------------"

data_files_big.each do |file|
  data = JSON.parse(File.read(file))

  puts "\nFile: #{file}".cyan
  #nearest_neighbor
  nn_result = NNSolver.solve(data)
  puts "Nearest Neighbor result: " + nn_result[:cost].to_s

  #2-opt
  k2_result = KOptSolver.solve(data,2)
  puts "2-opt result: " + k2_result.to_s

  #3-opt
  k3_result = KOptSolver.solve(data,3)
  puts "3-opt result: " + k3_result.to_s

  #2-opt based on nn
  k2_nn_result = KOptSolver.solve(data,2, nn_result[:result_path])
  puts "NN based 2-opt result: " + k2_nn_result.to_s

  #3-opt based on nn
  k3_nn_result = KOptSolver.solve(data,3, nn_result[:result_path])
  puts "NN based 3-opt result: " + k3_nn_result.to_s

  #Ant Colony
  aco = AcoSolver.new(data, 100)
  aco_result = aco.solve
  aco_cost = aco_result[:cost]
  puts "aco result: " + aco_cost.to_s
end
