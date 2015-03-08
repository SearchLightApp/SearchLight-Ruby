# encoding: utf-8


require 'capybara'
# require 'spec_helper'
require 'capybara/poltergeist'

# might need to gem install selenium and selenium-webdriver, for some reason
# gem install poltergeist
# brew install phantomjs


class ProfilePopulator
	include Capybara::DSL # used instead of manually starting session

	def initialize()
		# TO INSPECT YOUR PAGE'S CONSOLE:
		# 	page.driver.debug
		Capybara.register_driver :poltergeist_debug do |app|
			Capybara::Poltergeist::Driver.new(app, :inspector => true)
		end

		# headless
		Capybara.register_driver :poltergeist do |app|
			Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--debug=no', '--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'], :debug => false)
		end

		Capybara.default_driver = :selenium # or :selenium
		Capybara.javascript_driver = :poltergeist

		@session = Capybara::Session.new(:poltergeist)
		@session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X)' }
	end

	def searchTerms(terms, loc)
		link = "https://www.google.com/search?q="+terms
		@session.visit link

		# search for terms
		# fill_in "q", with: terms
		# if has_button?("gbqfb")
		# 	click_button "gbqfb"
		# else
		# 	click_button "Google Search"
		# end

		setSearchLocation(loc)
		sleep(2) #TODO Find a better solution to this
		if @session.has_css?("#res")
			links = @session.all("#res h3 a")
		end
		#Encode the necessary information from each HTML element into a Ruby hash
		links.map{|elem| {txt: elem.text, url: elem[:href]}}
	end

	# TODO: ideally, user would be able to select from account base
	def signIn()
		@session.visit 'http://plus.google.com'

		@session.fill_in 'Email', :with => 'xray.app.1'
		@session.fill_in 'Passwd', :with => 'xraymyass'

		@session.uncheck 'PersistentCookie'

		@session.click_on 'signIn'

		return true
	end

	def setProfileLocation(loc)
		# hover on Home and click Profile
		@session.find('a[title="Home"]').hover
		@session.find('a[aria-label="Profile"]').click
		# page.save_screenshot 'profile.png' #optional
		@session.find('span[data-dest="about"]').click
		# page.save_screenshot 'about.png' #optional

		# find location block
		within(:xpath, '//*[@id="12"]') do
			@session.find('span', text:'Edit', exact:true).click
		end

		# places pop up
		within(:xpath, '//*[@class="G-q-B"]') do
			@session.first(:css, 'input[label="type a city name"]').set loc

			@session.first(:css, 'span[aria-checked]').set 'true' # THIS ISNT WORKING FSR
			@session.find('div[guidedhelpid="profile_save"]', text:'Save').click
		end
	end

	def setSearchLocation(loc)

		# first turn off personal results
		# find_by_id("abar_ps_off").click
		# page.save_screenshot 'global.png'

		# page.driver.debug
		# save_and_open_page
		page.save_screenshot 'searchtools.png'

		@session.find(:xpath, '//*[@class="hdtb_tl"]').click

		options = @session.all(:css, 'div.hdtb-mn-hd')
		# puts options.length
		if options.empty?
			@session.find('a[id="hdtb_tls"]', text: 'Search tools').click
			options = @session.all(:css, 'div.hdtb-mn-hd')
		end
		options[2].click
		# save_and_open_page
		@session.fill_in 'lc-input', :with => loc
		#page.save_screenshot 'set_location_search.png'
		# click_on 'Set'
		@session.find('input[jsaction="loc.s"]').click
	end
# end ProfilePopulator
end