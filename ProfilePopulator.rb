require 'capybara'
# require 'spec_helper'

# might need to gem install selenium and selenium-webdriver, for some reason

# gem install poltergeist
# brew install phantomjs
# require 'capybara/poltergeist'

class ProfilePopulator
	include Capybara::DSL # used instead of manually starting session

	def initialize()
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

	def searchTerms(terms, loc)
		link = "https://www.google.com/search?q="+terms
		visit link

		# search for terms
		# fill_in "q", with: terms
		# if has_button?("gbqfb")
		# 	click_button "gbqfb"
		# else
		# 	click_button "Google Search"
		# end

		setSearchLocation(loc)
		if has_css?("#res")
			links = all("#res h3 a")
			# write out links to console
			# links.each do |link|
			# 	#puts link.text
			# 	#puts link[:href]
			# 	#puts ""
			# end
		end
		#Encode the necessary information from each HTML element into a Ruby hash
		links.map{|elem| {txt: elem.text, url: elem[:href]}}
	end

	# TODO: ideally, user would be able to select from account base
	def signIn()
		visit 'http://plus.google.com'

		fill_in 'Email', :with => 'xray.app.1'
		fill_in 'Passwd', :with => 'xraymyass'

		uncheck 'PersistentCookie'

		click_on 'signIn'

		return true
	end

	def setProfileLocation(loc)
		# hover on Home and click Profile
		find('a[title="Home"]').hover
		find('a[aria-label="Profile"]').click
		# page.save_screenshot 'profile.png' #optional
		find('span[data-dest="about"]').click
		# page.save_screenshot 'about.png' #optional

		# find location block
		# TODO identify with something other than id?
		within(:xpath, '//*[@id="12"]') do
			find('span', text:'Edit', exact:true).click
		end

		# places pop up
		within(:xpath, '//*[@class="G-q-B"]') do
			first(:css, 'input[label="type a city name"]').set loc
			# fill_in 'type a city name', :with => loc
			first(:css, 'span[aria-checked]').set 'true' # THIS ISNT WORKING FSR
			find('div[guidedhelpid="profile_save"]', text:'Save').click
			#page.save_screenshot 'set_location.png'
		end
	end

	def setSearchLocation(loc)
		# first turn off personal results
		# find_by_id("abar_ps_off").click
		#page.save_screenshot 'global.png'

		find('a[role="button"]', text: 'Search tools').click
		page.save_screenshot 'searchtools.png'

		options = all(:css, 'div.hdtb-mn-hd')
		# puts options.length
		if options.empty?
			find('a[id="hdtb_tls"]', text: 'Search tools').click
			options = all(:css, 'div.hdtb-mn-hd')
		end
		options[2].click
		# save_and_open_page
		fill_in 'lc-input', :with => loc
		page.save_screenshot 'set_location_search.png'
		# click_on 'Set'
		find('input[jsaction="loc.s"]').click
	end
# end ProfilePopulator
end