require_relative 'SearchParser'
require_relative 'Results'

s = SearchParser.new
r = $res

## TODO Store Query results in an honest-to-goodness class

topics = ['Abortion', 'Immigration', 'Loans', 'Healthcare']
cities = ['Birmingham, AL', 'Phoenix, AZ', 'San Francisco, CA', 'New York, NY', 'Birmingham, AL', 'Yarmouth, MA', 'Miami, Florida', 'El Paso, TX', 'Minneapolis, MN']
focus_topic = topics[1]
focus_city = cities[0]


s.GlobalComparison(cities[0],r,topics[1])
puts "+++++++++++++++++++++++++++++++++++++"
s.GlobalComparison(cities[1],r,topics[1])

#puts "COMPARE: <<" + focus_topic + ">> in " +focus_city+" to national results: \n"
#$res.each do |key, value|
#  puts "--------------------------------------------"
#  puts key # key = city, value = city's hash of topics
#  s.ComparisonPrint(r[focus_city][focus_topic], r[key][focus_topic]);
#end