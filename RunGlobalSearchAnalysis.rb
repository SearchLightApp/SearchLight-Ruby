require 'rubygems'
require 'mongoid'
require_relative './SearchComparison'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'
require_relative './LocalConfig'

#puts "Sorry Charlie, this isn't implemented yet."
#exit 0

if ARGV.length != 1
  puts "Incorrect number of arguments."
end

Mongoid.load!(LocalConfig.path_to_db_config, LocalConfig.db_config_id)
SearchComparison.GlobalSearchResultAnalysis(ARGV[0])
