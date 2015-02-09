require 'capybara'
# might need to gem install selenium and selenium-webdriver, for some reason

class ProfilePopulator
	include Capybara::DSL # used instead of manually starting session

	def initialize
		Capybara.default_driver = :selenium
	end

	# TODO: feed array of items to search / allow customization
	def searchTerms()
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
		end
	end

	def signIn()
		visit 'http://plus.google.com'

		fill_in 'Email', :with => 'xray.app.1'
		fill_in 'Passwd', :with => 'xraymyass'
		click_on 'signIn'
	end
# end ProfilePopulator
end

g = ProfilePopulator.new.signIn