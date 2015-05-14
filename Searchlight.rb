require 'mongoid'
require_relative 'Searcher'
require_relative './Model/Query'
require_relative './Model/Result'

path_to_db_config = './Model/mongoid.yml' #This file tells the program where to find the Database
Mongoid.load!(path_to_db_config, :development)

place = "New York"
term = "Jews"




arr = Searcher.conductSearch({:username => 'xray.app.1', :passwd => 'xrayalltheasses'}, place, term, 1, false)

qq = Query.new()
qq.query = "Batman"
qq.location = "Gotham"

res = []

arr.each do |elem|
  res.push()
  a_res Result.new(position: 2, url:"www.nrobin.com", txt: "nananana")
end

qq.save