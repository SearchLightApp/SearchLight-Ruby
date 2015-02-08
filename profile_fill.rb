require 'capybara'
# might need to gem install selenium, for some reason
class ProfilePopulator
	include Capybara::DSL # used instead of manually starting session

	def initialize
		Capybara.default_driver = :selenium
	end

	def accessGoogPlus()
		link = "http://www.google.com"
		terms = 'hello world'
		visit link

		# search for terms
		fill_in "q", with: terms
		if has_button?("gbqfb")
			click_button "gbqfb"
		else
			click_button "Google Search"
		end

		if has_css?("#res")
			links = all("#res h3 a")
			links.each do |link|
			puts link.text
			puts link[:href]
			puts ""
		end

		return 'done ======== '
	end
# end ProfilePopulator
end

# test script
g = ProfilePopulator.new.accessGoogPlus
puts g
end
