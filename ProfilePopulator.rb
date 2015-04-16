# encoding: utf-8
require 'capybara'
require 'capybara/poltergeist'

class ProfilePopulator
  include Capybara::DSL # used instead of manually starting session

  # DRIVERS
  # To inspect page console: page.driver.debug
  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end
  # headless
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'], :debug => false)
  end
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app)
  end

  def initialize()
    Capybara.current_driver = :poltergeist
    # Capybara.javascript_driver = :pant_debug

    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36' } # spoof user
    Capybara.run_server = false
  end

  attr_accessor :session

# function copied over from Francis, pretty much 
  def getAds(string, page)
    puts 'get ads'
    query = "https://www.google.com/search?q=#{string.gsub(/ /, '+')}&start=#{10*(page-1)}"
    @session.visit(query)
    sleep(2) #TODO Find a better solution to this
    begin
      @session.find(:xpath, '//*[@id="mbEnd"]/h2/span[2]/a').click
    rescue
      begin
        @session.find(:xpath, '//*[@id="tads"]/h2/span/a').click
      rescue
        begin
        @session.find(:xpath, '//*[@id="tadsb"]/h2/span/a').click
        rescue
          return nil
        end
      end
    end
    sleep(1)
    @session.find(:xpath, '//*[@id="abbl"]/div/div[2]/a').click
    sleep(1)
    
    ads_list = @session.all('div.HK').map{|a| a.all('div.eB')}
    ads = []
    ads_list.each do |ad|
      ad_info = ad.first.all('div').map{|e| e.text}
      ad_text = ad_info[1]
      ad_url = ad_info[2]
      ad_description = ad_info[3..ad_info.count].join(' ')
      ad_truth = ad.last.all('div').map{|e| e.text}
      puts ad_info, ad_text, ad_url
      if ad_truth[3] =~ /This ad matches the exact search you entered/
        truth = {behavioral: false, google_explanation: ad_truth[3]}
      elsif ad_truth[3] =~ /This ad matches terms similar to the ones you entered/
        if ad_truth.count == 5
          truth = {behavioral: false, google_explanation: ad_truth[3]}
        else
          truth = {behavioral: true, google_explanation: ad_truth[3], web_hist: ad_truth[7..-2]}
        end
      end
      puts ad_text, ad_url, ad_description, page, truth
      ads.push({text_of_link: ad_text,
                non_clickable_url: ad_url,
                description: ad_description,
                page: page,
                truth: truth})
    end
    return ads
  end

# before searching for the given string, sets the Location of search and then returns a dict w each result
  def getSearch(string, loc, page)
    query = "https://www.google.com/search?q=#{string.gsub(/ /, '+')}&start=#{10*(page-1)}"
    @session.visit(query)

    setSearchLocation(loc)
    if @session.has_css?("#res")
      links = @session.all("#res h3 a")
    end
    return links.map{|elem| {txt: elem.text, url: elem[:href]}}
    #Encode the necessary information from each HTML element into a Ruby hash
  end

# visits the login page for an account and unchecks 'stay signed in'
  def login!(account, link = 'https://accounts.google.com/ServiceLogin?hl=en')
    @session.visit(link)
    @session.within("form#gaia_loginform") do
      @session.fill_in 'Email', :with => (account[:username] || account["username"])
      @session.fill_in 'Passwd', :with => (account[:passwd] || account["passwd"])
    end
    @session.uncheck 'Stay signed in'
    @session.click_on 'Sign in'
  end

  ## This function originally went to Google+ profile, and changed location ##
  # def setProfileLocation(loc)
  #   # hover on Home and click Profile
  #   @session.find('a[title="Home"]').hover
  #   @session.find('a[aria-label="Profile"]').click
  #   # page.save_screenshot 'profile.png' #optional
  #   @session.find('span[data-dest="about"]').click
  #   # page.save_screenshot 'about.png' #optional

  #   # find location block
  #   within(:xpath, '//*[@id="12"]') do
  #   @session.find('span', text:'Edit', exact:true).click
  #   end

  #   # places pop up
  #   within(:xpath, '//*[@class="G-q-B"]') do
  #   @session.first(:css, 'input[label="type a city name"]').set loc

  #   @session.first(:css, 'span[aria-checked]').set 'true' # THIS ISNT WORKING FSR
  #   @session.find('div[guidedhelpid="profile_save"]', text:'Save').click
  #   end
  # end

# changes the location on the gsearch page
  def setSearchLocation(loc)
    # @session.save_and_open_screenshot('searchA.png')
    # puts @session.body

    # first turn off personal results
    # @session.find('a[id="abar_ps_off"]').click
    # puts @session.body
    # @session.save_and_open_screenshot('personresultsA.png')
    # @session.save_and_open_screenshot()

    # puts @session.body
    # puts 'hello-world'
    # first turn off personal results
    @session.find('a[id="abar_ps_off"]').click

    # puts options.length
    options[2].click

    sleep(2)
    puts 'length of options:', options.length
    options[2].click
    @session.save_screenshot 'lc input.png'
    @session.fill_in 'lc-input', :with => loc
    @session.find('input[jsaction="loc.s"]').click
  end

# clear all cookies from the session and reset it
  def clean
    @session.driver.browser.manage.delete_all_cookies
    @session.reset!
  end

  # {:username => 'xray.app.1', :passwd => 'xraymyass'}
  def self.test(account, loc, query, page)
    pPop = self.new

    if pPop.login!(account)
      search = pPop.getSearch(query, loc, page)
      ads = pPop.getAds('cancer', 1)
    end
  end

end # end ProfilePopulator

ProfilePopulator.test