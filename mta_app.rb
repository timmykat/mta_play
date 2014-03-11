require 'rubygems'
require 'bundler/setup'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'pry'
require 'sqlite3'
require 'dm-rspec'

require_relative 'config'
require_relative 'mta_models'
require_relative 'db_init'

def mta_help
  puts "\nRider types: \n- regular (default)\n- student\n- elderly\n- employee\n\n"
  puts "Transport types: \n- bus (default)\n- subway\n- commuter_rail\n- special_bus\n\n"
  puts "Recommended sequence:\n"
  puts "  1. Create a rider:        r = Rider.new(type: 'student')\n"
  puts "  2. Purchase card:         c = r.purchase_card(pass: 'commuter_rail') or c = r.purchase_card(amount: 20.00)\n"
  puts "  3. Swipe card to travel:  c.swipe('bus')\n\n"
  puts "(mta_help gets this list)\n"
end

mta_help
