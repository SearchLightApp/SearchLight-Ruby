require 'rubygems'
require 'mongoid'
require 'mongo'
require_relative './Model/Query'
require_relative './Model/Ad'
require_relative './Model/Result'

class SearchComparison

  # def initialize(q, city)
  #   GlobalComparison(city, q, $res)
  # end

  def initialize(ip, db_name, q, city)
    db = Mongo::Connection.new(ip).db(db_name)
    coll = db.collection("queries")
    fetched = coll.find({
     'query' => q})
    r = formatResults(fetched)
    GlobalComparison(city, q, r)
  end

  def formatResults(res)
    results = {} # the results to be compared given a query
    res.each do |r|
      formatted = []
      r['results'].each do|fr| # formatted results
        formatted << {:txt=> fr['txt'], :url=> fr['url']}
      end
      results[r['location']] = formatted
    end
    return results
  end

# make into an array and subtract
	def SearchComp(a,b)
		a.to_a - b.to_a
  end

# compare the indeces in all search results
	def Permutation(a,b)
		score = []
		a.each_index do |i|
			b_index = b.index(a[i])
			if b_index.nil?
				score.push( nil )
			else
				score.push(i - b_index)
			end
		end
		score
  end

  # return true if a and b are the same
  def ComparisonPrint(a,b)
    same = true
    score = []
    a.each_index do |i|
      b_index = b.index(a[i]) # get in b what is in a's index position
      if not b_index.nil? # if b is not nil
        diff = i - b_index # compare the elements at same index in a & b
        if diff != 0
          same = false
          puts sprintf("%+d", diff.to_s) + "  " + a[i][:txt]
        end
      else
        puts "NA" + "  " + a[i][:txt]
      end
    end
    return same
  end

  def self.GlobalComparison_DB(focus_city, topic)

    focus_res = Query.where(location: focus_city).where(query: topic).first #TODO: Don't just get the first one. Allow choosing of date.
    if focus_res.nil?
      puts "ERROR: Could not find query '"+ topic +"' for city: " + focus_city
      return
    end
    puts "TOPIC:\t\t"  + topic
    puts "LOCATION:\t" + focus_city
    puts "DATE:\t\t"   + focus_res.created_at.to_s #TODO: Use a better string conversion for timestamps
    puts "RESULTS:\t"  + focus_res.results.length.to_s

    extractResList(Query.where(query: topic).first)

    # Retrieve all queries matching a given topic. Except the focus result
    all_topic_queries = Query.where(query: topic).not.where(id: focus_res.id)
    all_topic_queries.each do |q|
      puts "-----------"
      puts q.location + " @ " + q.created_at.to_s
    end

  end

  #Drop all the infromation from Result objects which is not important to distinguish between sets of results. For example the Result ID
  def self.extractResList(query)
    rmap = query.results.map do |res|
      res.txt
      #[txt: res.txt, url: res.url] #TODO Should we use URL to distinguish?
    end
    return rmap
  end

  def GlobalComparison(focus_city, topic, res_db)
    res_to_index = {}
    focus_city_array = nil
    res_db.each do |cityname , cityhash|
      if cityname != focus_city
        # an array of hashes that look like {:txt, :url}
        cityresults = cityhash # change to cityhash[topic] if using dummy results file
        res_to_index[cityresults] ||= []
        res_to_index[cityresults].push(cityname)
      else
        focus_city_array = cityhash # change to cityhash[topic] if using dummy results file
        puts "COMPARE:\t"+ cityname
        puts "TOPIC:\t"  + topic
        puts "RESULTS:\t"+ focus_city_array.length.to_s
      end
    end
    if focus_city_array.nil?
      abort('Could not find focus city')
    end
    res_to_index.each do |q_results, citynames|
      puts ""
      any_diff = false
      puts q_results.length.to_s + " results for:"
      puts citynames
      focus_city_array.each_index do |element_index|
        index_in_other = q_results.index(focus_city_array[element_index])
        if index_in_other.nil?
          puts "\tREM" + "  " + focus_city_array[element_index][:txt]
          any_diff = true
        else
          diff = element_index - index_in_other
          if diff != 0
            puts sprintf("\t%+d ", diff.to_s) + "  " + focus_city_array[element_index][:txt]
            any_diff = true
          end
        end
      end
      q_results.each_index do |element_index|
        index_in_other = focus_city_array.index(q_results[element_index])
        if index_in_other.nil?
          puts "\tADD" + "  " + q_results[element_index][:txt]
          any_diff = true
        end
      end
      if !any_diff
        puts "\tNo difference"
      end
    end
  end

end

# c = SearchComparison.new("104.131.15.123", "alpha_testing", ARGV[0], ARGV[1])
# c = SearchComparison.new(ARGV[0], ARGV[1])

path_to_db_config = './Model/mongoid.yml'
Mongoid.load!(path_to_db_config, :jumpingcrab)
SearchComparison.GlobalComparison_DB("10027", "I need money")