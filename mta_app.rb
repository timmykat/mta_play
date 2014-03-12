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
  puts "Recommended sequence:\n"
  puts "  1. Create a rider:        r = Rider.create\n"
  puts "  2. Purchase card:         c = r.purchase_card(rider_type: 'student', pass_type: 'commuter_rail') or c = r.purchase_card(rider_type: 'elderly', amount: 20.00)\n"
  puts "  3. Swipe card to travel:  c.swipe('bus')\n\n"
  puts "(mta_help gets this list)\n"
end

mta_help

# puts "Creating a rider and some default Oyster Cards:"
# @r = Rider.create
# puts '@oc_subway'
# @oc_subway   = @r.purchase_card(:rider_type => 'regular', :pass_type => 'subway')
# puts '@oc_bus'
# @oc_bus      = @r.purchase_card(:rider_type => 'student', :pass_type => 'bus')
# puts '@oc_per_ride'
# @oc_per_ride = @r.purchase_card(:rider_type => 'regular', :amount => 40.00)
