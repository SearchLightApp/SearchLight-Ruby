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

  def SearchComparisonPrint(a,b)
    score = []
    a.each_index do |element_index|
      index_in_b = b.index(a[element_index])
      if not index_in_b.nil?
        diff = element_index - index_in_b
        if diff != 0
          puts diff.to_s + "  " + a[element_index][:txt]
        end
      end
    end
  end

  def SearchPrint(a)
    a.each do |elem|
      puts elem[:txt]
      puts elem[:url]
    end
  end
end

