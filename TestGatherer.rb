require 'mongoid'
require_relative './Model/Query'
require_relative './Model/Result'
require_relative 'Results'

path_to_db_config = './Model/mongoid.yml' #This file tells the program where to find the Database
Mongoid.load!(path_to_db_config, :development)


qq = Query.new()
qq.query = "Batman"
qq.location = "Gotham"

ra = Result.new(position: 1, url:"www.batmobile.com", txt:"Buy a bat car" )
rb = Result.new(position: 2, url:"www.nrobin.com", txt: "nananana")
qq.results = [ra, rb]

qq.save


#Example: This is how to store a search result

=begin
$res.each do |locationname , cityhash|
  cityhash.each do |searchterm, resultarray|
    sr = SearchResult.new(query: searchterm, location: locationname, results: resultarray)
    sr.save()
  end
end
=end

=begin

path_to_db_config = './magic/config/mongoid.yml'
Mongoid.load!(path_to_db_config, :development)

me = Person.new(first_name: "Max", middle_name: "Lee", last_name: "Tucker")

me.save()

print Person.first

Person.collection.drop()

=end