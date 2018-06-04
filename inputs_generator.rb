# текущий уровень сахара в крови, ХЕ, будущий уровень сахара в крови
# 1 хе = 0.24 mmol/l через 2 часа с учетом инсулина
require 'ruby-fann'
require 'pry'

before_food = (3.2..5.5).step(0.01).to_a

x_data = []
y_data = []
after_food = []

(1..9).to_a.each do |i|
  before_food.each do |e|
  	i = i.to_f
    after_food.push [e, i, (e+(i*0.24))]
    x_data.push [e,i]
    y_data.push [(e+(i*0.24))]
  end
end

test_size_percentange = 20.0 # 20.0%
test_set_size = x_data.size * (test_size_percentange/100.to_f)

test_x_data = x_data[0 .. (test_set_size-1)]
test_y_data = y_data[0 .. (test_set_size-1)]

training_x_data = x_data[test_set_size .. x_data.size]
training_y_data = y_data[test_set_size .. y_data.size]

train = RubyFann::TrainData.new( inputs: training_x_data, desired_outputs: training_y_data)

model = RubyFann::Standard.new(
  num_inputs: 2,
  hidden_neurons: [60],
num_outputs: 1 )
model.set_activation_function_output(:linear) 

model.train_on_data(train, 5000, 500, 0.01)
neurons = model.get_neurons
connections = model.get_total_connections
puts "#{neurons}"
puts "#{connections}"
puts "#{model.get_training_algorithm}"

prediction = model.run( [3.9, 5.0] )

puts "Algorithm predicted class: #{prediction}"

predicted = []
test_x_data.each do |params|
  predicted.push( model.run(params) )
end

test_y_data.size.times { |t| puts "NN predicted #{predicted[t]}, result #{test_y_data[t]}" }

error = []
test_y_data.size.times { |t| error.push(test_y_data[t][0] - predicted[t][0])}
general_error = error.inject {|s,e| 100.0 - (((s+e) / error.size) * 100)}

puts "NN Accuracy: #{general_error}%"

