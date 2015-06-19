require 'mongoid'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'

path_to_db_config = './Model/mongoid.yml'
Mongoid.load!(path_to_db_config, :jumpingcrab)

puts Query.where(query: "I need money").count
puts Query.where(query: "I need money").not.where(id: "556e2fef4365632a30290000").count

exit

q = Query.where(query: "I need money").first

puts q.id

rmap= q.results.map do |res|
    [res.txt, res.url]
end

rmap.each do |r|
  puts "_______"
  puts r
  puts "_______"
end