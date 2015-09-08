require 'rubygems'
require 'mongoid'
require_relative './SearchComparison'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'


path_to_db_config = './Model/mongoid.yml'
Mongoid.load!(path_to_db_config, :cathy)
SearchComparison.GlobalComparison_DB("10027", "how do i get food stamps")
