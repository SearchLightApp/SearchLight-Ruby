require 'capybara'
# might need to gem install selenium and selenium-webdriver, for some reason

# gem install poltergeist
# brew install phantomjs
# require 'capybara/poltergeist'

class ProfilePopulator
	include Capybara::DSL # used instead of manually starting session

	def initialize
		Capybara.default_driver = :selenium

		# TODO: move to phantomJS or so bc firefox is annoying
		# Capybara.configure do |config|
		# 	config.run_server = false
		# 	config.default_driver = :poltergeist
		# end
		# Capybara.register_driver :poltergeist do |app|
		# 	Capybara::Poltergeist::Driver.new(app, { window_size: [1600, 3500] })
		# end
	end

	# TODO: feed array of items to search / allow customization
	# def searchTerms()
	# 	link = "http://www.google.com"
	# 	terms = 'hello world'
	# 	visit link

	# 	# search for terms
	# 	fill_in "q", with: terms
	# 	if has_button?("gbqfb")
	# 		click_button "gbqfb"
	# 	else
	# 		click_button "Google Search"
	# 	end

	# 	if has_css?("#res")
	# 		links = all("#res h3 a")
	# 		links.each do |link|
	# 			puts link.text
	# 			puts link[:href]
	# 			puts ""
	# 		end
	# 	end
	# end

	# TODO: ideally, user would be able to select from account base
	def signIn()
		visit 'http://plus.google.com'

		fill_in 'Email', :with => 'xray.app.1'
		fill_in 'Passwd', :with => 'xraymyass'
		click_on 'signIn'

		setProfile()
	end

	def setProfile()
		# hover on Home and click Profile
		find('a[title="Home"]').hover
		find('a[aria-label="Profile"]').click
		page.save_screenshot 'profile.png'
		find('span[data-dest="about"]').click
		page.save_screenshot 'about.png'

		find_by_id('12').find('span', text:'Edit', exact:true).click

		fill_in 'type a city name', :with => 'Portland, OR'
		first(:css, 'span[role="checkbox"]').set(true)
		page.save_screenshot 'set_location.png'
		find('div', text:'Save', exact:true).click
		# popup = page.driver.browser.window_handles.last

	end


# end ProfilePopulator
end

g = ProfilePopulator.new.signIn