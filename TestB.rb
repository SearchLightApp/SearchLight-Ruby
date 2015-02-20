require_relative 'SearchParser'
require_relative 'Results'

s = SearchParser.new
r = $res

topics = ['Abortion', 'Immigration', 'Loans', 'Healthcare']
cities = ['Birmingham, AL', 'Phoenix, AZ', 'San Francisco, CA', 'New York, NY', 'Birmingham, AL', 'Yarmouth, MA', 'Miami, Florida', 'El Paso, TX', 'Minneapolis, MN']
focus_topic = topics[1]
focus_city = cities[0]

puts "COMPARE: <<" + focus_topic + ">> in " +focus_city+" to national results: \n"
$res.each do |key, value|
  puts "--------------------------------------------"
  puts key # key = city, value = city's hash of topics
  s.SearchComparisonPrint(r[focus_city][focus_topic], r[key][focus_topic]);
end