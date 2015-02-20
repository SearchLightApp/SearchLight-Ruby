require 'capybara'
#
# Import
#

class SearchParser
  def initialize()
  end

	def SearchComp(a,b)
		a.to_a - b.to_a
  end

	def SearchPermute(a,b)
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
  def SearchComparisonPrint(a,b)
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
      end
    end
    return same
  end

  def SearchPrint(a)
    a.each do |elem|
      puts elem[:txt]
      puts elem[:url]
    end
  end
end

