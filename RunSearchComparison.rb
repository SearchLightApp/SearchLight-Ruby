require 'rubygems'
require 'mongoid'
require_relative './SearchComparison'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'
require_relative './Config'


Mongoid.load!(Config.path_to_db_config, Config.db_config_id)
SearchComparison.GlobalComparison("10027", "how do i get food stamps")
