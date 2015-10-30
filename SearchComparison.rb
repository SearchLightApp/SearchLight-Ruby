require 'rubygems'
require 'mongoid'
#require 'mongo'
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
    GlobalComparison(city, q, r) #TODO: Why is this getting called here?
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

  def self.AdFrequencyAnalysis(focus_city, topic)
    focus_res = Query.where(location: focus_city).where(query: topic)
    if focus_res.nil?
      puts "WARNING: Could not find query '"+ topic +"' for location '" + focus_city + "'"
      return
    end

    adcounts = {}
    focus_res.each do |fr|
      fr.ads.each do |ad|
        adcounts[ad.adtxt] ||= 0
        adcounts[ad.adtxt]  += 1
      end
    end
    impressions = focus_res.length
    puts "TOPIC:\t\t "  + topic
    puts "LOCATION:\t " + focus_city
    puts "IMPRESSIONS: " + impressions.to_s
    adcounts.each do |adtxt , adcount|
      puts adcount.to_s + "\t" + (adcount.fdiv(impressions)*100).round(1).to_s.rjust(5,"0") + "%\t" + adtxt
    end
  end

  def self.GlobalAdFrequencyAnalysis(topic) #TODO : Distinguish by ad URL as well as text? USE IDENTIFIER METHOD ON AD AND RESULT OBJECTS
    focus_res = Query.where(query: topic)
    if focus_res.empty?
      puts "WARNING: Could not find any entries for query '"+ topic +"'"
      return
    end

    # and ad is identified by a pair [txt, url]. call this an ad key
    adcounts = {} # 2D array mapping a location and ad to number of times the ad was seen at that location
    location_impressions = {} # total number of impressions that are in the DB for a given location
    ad_impressions = {} # total number of impressions that are in the DB for a given location (This can be computed from location_impressions but the set of keys here is also useful)
    focus_res.each do |fr|
      # Count impressions for this location
      location_impressions[fr.location] ||= 0
      location_impressions[fr.location]  += 1
      # Count sightings of each ad.
      adcounts[fr.location] ||= {}
      fr.ads.each do |ad|
        # Counting ad impressions per location
        adcounts[fr.location][ad.identifier] ||= 0
        adcounts[fr.location][ad.identifier]  += 1
        # Counting overall ad impressions
        ad_impressions[ad.identifier] ||= 0
        ad_impressions[ad.identifier]  += 1
      end
    end

    total_impressions = focus_res.length

    #CSV OUTPUT CODE
    puts "TOPIC," + topic.to_s.gsub(/\,/,"")
    puts "IMPRESSIONS," + total_impressions.to_s

    # Print header Line
    ln = "AD TEXT,AD URL,AD IMPRESSIONS,"
    location_impressions.keys.sort.each do |locationkey|
      ln += locationkey.to_s.gsub(/\,/,"") + ','
    end
    puts ln

    # Print table body
    ad_impressions.each do |adkey , count|
      ln =  adkey[0].to_s.gsub(/\,/,"") + ',' + adkey[1].to_s.gsub(/\,/,"") + ',' + count.to_s + ','
      location_impressions.keys.sort.each do |locationkey|
        ln += adcounts[locationkey][adkey].to_s + ','
      end
      puts ln
    end

    # Print footer line
    ln = "TOTAL IMPRESSIONS AT LOCATION,,"
    location_impressions.keys.sort.each do |locationkey|
      ln += location_impressions[locationkey].to_s + ','
    end
    puts ln

  end

  def self.GlobalSearchResultAnalysis(topic)
    focus_res = Query.where(query: topic)
    if focus_res.empty?
      puts "WARNING: Could not find any entries for query '"+ topic +"'"
      return
    end

    # and ad is identified by a pair [txt, url]. call this an ad key
    searchcounts = {} # 2D array mapping a location and ad to number of times the ad was seen at that location
    location_impressions = {} # total number of impressions that are in the DB for a given location
    search_impressions = {} # total number of impressions that are in the DB for a given location (This can be computed from location_impressions but the set of keys here is also useful)
    focus_res.each do |fr|
      # Count impressions for this location
      location_impressions[fr.location] ||= 0
      location_impressions[fr.location]  += 1
      # Count sightings of each ad.
      searchcounts[fr.location] ||= {}
      fr.results.each do |result|
        # Counting ad impressions per location
        searchcounts[fr.location][result.identifier] ||= 0
        searchcounts[fr.location][result.identifier]  += 1
        # Counting overall ad impressions
        search_impressions[result.identifier] ||= 0
        search_impressions[result.identifier]  += 1
      end
    end

    total_impressions = focus_res.length

    #CSV OUTPUT CODE
    puts "TOPIC," + topic.to_s.gsub(/\,/,"")
    puts "IMPRESSIONS," + total_impressions.to_s

    # Print header Line
    ln = "Result TEXT,Result URL,Result IMPRESSIONS,"
    location_impressions.keys.sort.each do |locationkey|
      ln += locationkey.to_s.gsub(/\,/,"") + ','
    end
    puts ln

    # Print table body
    search_impressions.each do |resultkey , count|
      ln =  resultkey[0].to_s.gsub(/\,/,"") + ',' + resultkey[1].to_s.gsub(/\,/,"") + ',' + count.to_s + ','
      location_impressions.keys.sort.each do |locationkey|
        ln += searchcounts[locationkey][resultkey].to_s + ','
      end
      puts ln
    end

    # Print footer line
    ln = "TOTAL IMPRESSIONS AT LOCATION,,"
    location_impressions.keys.sort.each do |locationkey|
      ln += location_impressions[locationkey].to_s + ','
    end
    puts ln

  end

  def self.GlobalComparison(focus_city, topic)

    focus_res = Query.where(location: focus_city).where(query: topic).first #TODO: Don't just get the first one. Allow choosing of date.
    if focus_res.nil?
      puts "WARNING: Could not find query '"+ topic +"' for location '" + focus_city + "'"
      return
    end
    puts "TOPIC:\t\t"  + topic
    puts "LOCATION:\t" + focus_city
    puts "DATE:\t\t"   + focus_res.created_at.to_s #TODO: Use a better string conversion for timestamps
    puts "RESULTS:\t"  + focus_res.results.length.to_s

    focus_reslist = extractResList(Query.where(query: topic).first)
    # A hash array tha maps sets of results to queries. We will use this to associate queries with identical results
    res_to_query = {}

    # Retrieve all queries matching a given topic. Except the focus result
    all_topic_queries = Query.where(query: topic).not.where(id: focus_res.id)
    all_topic_queries.each do |q|
      #TODO remove
      #puts "-----------"
      #puts q.location + " @ " + q.created_at.to_s
      q_reslist = extractResList(q)
      res_to_query[q_reslist] ||= []
      res_to_query[q_reslist].push(q)
    end

    res_to_query.each do |q_reslist , q_List|
      any_diff = false
      puts "Result Group:"
      puts q_List.map{ |q| "\t" + q.location + " @ " + q.created_at.to_s}
      puts "\t\tResults: (" + q_reslist.length.to_s + " total)"
      focus_reslist.each do |res|
        index_in_query = q_reslist.index(res)
        if index_in_query.nil?
          puts "\t\t\tDEL" + "  " + res
          any_diff = true
        else
          diff = focus_reslist.index(res) - index_in_query
          if diff != 0
            puts sprintf("\t\t\t%+d ", diff.to_s) + "  " + res
            any_diff = true
          end
        end
      end
      q_reslist.each do |res|
        if focus_reslist.index(res).nil?
          puts "\t\t\tADD" + "  " + res
        end
      end
      if !any_diff
        puts "\t\tNo difference"
      end
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

=begin  THIS CODE HAS BEEN REPLACED BY A VERSION THAT USES THE DATABASE
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
=end

end

# EXAMPLE: TO RUN AD ANALYSIS
# path_to_db_config = './Model/mongoid.yml'
# Mongoid.load!(path_to_db_config, :jumpingcrab)
# SearchComparison.AdAnalysis("10027", "I need money")


# EXAMPLE: TO RUN SEARCH COMPARISON
#path_to_db_config = './Model/mongoid.yml'
#Mongoid.load!(path_to_db_config, :jumpingcrab)
#SearchComparison.GlobalComparison("10027", "I need money")