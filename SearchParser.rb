require 'capybara'
# Import

class SearchParser
  def initialize()
  end

	def SearchComp(a,b)
		a.to_a - b.to_a
  end

	def Permutation(a,b)
		score = []
		a.each_index do |element_index|
			index_in_b = b.index(a[element_index])
			if index_in_b.nil?
				score.push( nil )
			else
				score.push(element_index - index_in_b)
			end
		end
		score
  end

  # return true if a and b are the same
  def ComparisonPrint(a,b)
    same = true
    score = []
    a.each_index do |element_index|
      index_in_b = b.index(a[element_index]) # get in b what is in a's index position
      if not index_in_b.nil?
        diff = element_index - index_in_b # compare the elements at same index in a & b
        if diff != 0
          same = false
          puts sprintf("%+d", diff.to_s) + "  " + a[element_index][:txt]
        end
      else
        puts "NA" + "  " + a[element_index][:txt]
      end
    end
    return same
  end

  def GlobalComparison(focus_city, topic, res_db)
    res_to_index = {}
    focus_city_array = nil
    res_db.each do |cityname , cityhash|
      if cityname != focus_city
        cityresults = cityhash[topic] # an array of hashes that look like {:txt, :url}
        res_to_index[cityresults] ||= []
        res_to_index[cityresults].push(cityname)
      else
        focus_city_array = cityhash[topic]
        puts "COMPARE:\t"+ cityname
        puts "TOPIC:  \t"  + topic
        puts "RESULTS:\t"+ focus_city_array.length.to_s
      end
    end
    if focus_city_array.nil?
      abort('Could not find focus city')
    end
    res_to_index.each do |q_results, citynames|
      puts ""
      any_diff = false
      #puts q_results.length.to_s + " results for:"
      PrintCities(citynames)
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

  def PrintCities(cityname_array)
    puts cityname_array
  end


  def PrettyPrint(a)
    a.each do |elem|
      puts elem[:txt]
      puts elem[:url]
    end
  end
end

