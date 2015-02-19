require 'capybara'
#
# Import
#

class SearchParser

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
end

