require 'rubygems'
require 'mongoid'
require_relative './SearchComparison'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'
require_relative './LocalConfig'

if ARGV.length != 2
  puts "Incorrect number of arguments."
  exit
end

Mongoid.load!(LocalConfig.path_to_db_config, LocalConfig.db_config_id)
#SearchComparison.GlobalComparison("10027", "how do i get food stamps")
SearchComparison.GlobalComparison(ARGV[0], ARGV[1])