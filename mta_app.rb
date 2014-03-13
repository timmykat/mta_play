require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'sqlite3'
require 'dm-noisy-failures'
require 'dm-rspec'

require 'pry'
require 'pry-debugger'

require_relative 'config'
require_relative 'models'
require_relative 'db_init'
require_relative 'syntactic_sugar'

def mta_help
  puts "\nRider types: \n- regular (default)\n- student\n- elderly\n- employee\n\n"
  puts "Transport types: \n- bus (default)\n- subway\n- commuter_rail\n- special_bus\n\n"
  puts "Commands:\n"
  puts "- Purchase card: (default rider_type: regular)"   
  puts "--- card = OysterCard.purchase(rider_type: 'student', pass_type: 'commuter_rail') or "
  puts "--- card = OysterCard.purchase(rider_type: 'elderly', amount: 20.00)"
  puts "- Take a trip:"
  puts "--- card.swipe('bus')"
  puts "- This list:"
  puts "--- mta_help\n\n"
end

mta_help
