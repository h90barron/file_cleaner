File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'cleaner'

args = ARGV

input_file = (args[0].nil? ? 'input.csv' : args[0])
output_file = (args[1].nil? ? 'output.csv' : args[1])
validate = (args[2] == 'false' ? false : true)

Cleaner.new(
  input_file: input_file,
  output_file: output_file,
  validate: validate
).clean