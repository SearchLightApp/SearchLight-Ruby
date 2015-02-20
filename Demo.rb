require_relative 'SearchParser'
require_relative 'Results'

s = SearchParser.new
r = $res

## TODO Store Query results in an honest-to-goodness class
puts "Pick a city and a topic"
cities = $res.keys
topics = $res[cities[0]].keys
if ARGV.length == 0
  puts "Topics:"
  puts ((0..topics.length-1).zip topics).map{|a| a[0].to_s+"\t"+a[1].to_s}
  puts ""
  puts "Cities"
  puts ((0..cities.length-1).zip cities).map{|a| a[0].to_s+"\t"+a[1].to_s}
else
  focus_topic = topics[1]
  focus_city = cities[0]
  s.GlobalComparison(cities[ARGV[0].to_i],topics[ARGV[1].to_i],r)
end

#s.GlobalComparison(cities[0],topics[1],r)
#puts "+++++++++++++++++++++++++++++++++++++"
#s.GlobalComparison(cities[1],r,topics[1])

#puts "COMPARE: <<" + focus_topic + ">> in " +focus_city+" to national results: \n"
#$res.each do |key, value|
#  puts "--------------------------------------------"
#  puts key # key = city, value = city's hash of topics
#  s.ComparisonPrint(r[focus_city][focus_topic], r[key][focus_topic]);
#end