require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'pry'
require 'sqlite3'

require 'rspec-core'
require 'rspec-expectations'
require 'dm-rspec'


# Get configuration
$config = YAML::load(File.open('config.yml'))

# The following creates a charge lookup table based on (rider type, transport type, and method - pass or charge
$fee_lookup = {}
$config['rider'].each do |k, v|
  $fee_lookup[k] = {}
  $config['transport'].each do |kk, vv|
    $fee_lookup[k][kk] = {
      'pass' => v['discount'].to_f * vv['pass'].to_f,
      'fee'  => v['discount'].to_f * vv['fee'].to_f
    }
  end
end

require_relative 'mta_models'

# Configure DataMapper - use in-memory connection
DataMapper::Property::String.length(255)
DataMapper::Property::Boolean.allow_nil(false)
DataMapper::Model.raise_on_save_failure = true
DataMapper.setup(:default, 'sqlite::memory:')

# Create the tables
DataMapper.auto_migrate!

puts "Rider types: 'regular', 'student', 'elderly', 'employee'. Default is 'regular'\\n"
puts "Transport types: 'bus', 'subway', 'commuter_rail', 'special_bus'. Default is 'bus'\n\n"
puts "Recommended sequence:\n"
puts "  1. Create a rider:\n"
puts "     e.g. r = Rider.new(type: 'student')\n"
puts "  2. Purchase card:\n"
puts "     e.g. c = r.purchase_card(pass: 'commuter_rail') or c = r.purchase_card(amount: 20.00)\n\n"
puts "  3. Swip your card to board a type of transportation:\n"
puts "     e.g. c.swipe('bus')\n\n"
puts "Ok, go."
