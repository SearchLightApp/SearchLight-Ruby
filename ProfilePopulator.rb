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
    # Capybara.default_driver = :selenium
    Capybara.javascript_driver = :poltergeist_debug

    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X)' } # spoof user
    Capybara.run_server = false
  end

  attr_accessor :session

  def getAds(string, page)
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

      ads.push({text_of_link: ad_text,
                non_clickable_url: ad_url,
                description: ad_description,
                page: page,
                truth: truth})
    end
    return ads
  end

  def getSearch(string, page)
    query = "https://www.google.com/search?q=#{string.gsub(/ /, '+')}&start=#{10*(page-1)}"
    @session.visit(query)

    setSearchLocation('Ypsilanti, MI')
    if @session.has_css?("#res")
      links = @session.all("#res h3 a")
    end
    return links.map{|elem| {txt: elem.text, url: elem[:href]}}
    #Encode the necessary information from each HTML element into a Ruby hash
    # links.map{|elem| {txt: elem.text, url: elem[:href]}}
    #
  end

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

  def setSearchLocation(loc)
  # first turn off personal results
  # find_by_id("abar_ps_off").click

    puts "Body:" + page.body
    page.driver.debug
    sleep(2)
    @session.find(:xpath, '//*[@id="hdtb_tls"]').click
    options = @session.all(:css, 'div.hdtb-mn-hd')
    # puts options.length
    if options.empty?
      @session.find('a[id="hdtb_tls"]', text: 'Search tools').click
      options = @session.all(:css, 'div.hdtb-mn-hd')
    end

    options[2].click
    @session.fill_in 'lc-input', :with => loc
    @session.find('input[jsaction="loc.s"]').click
  end

  def clean
    @session.driver.browser.manage.delete_all_cookies
    @session.reset!
  end

  def self.test
    session = self.new
    account = {:username => 'xray.app.1', :passwd => 'xraymyass'}

    if session.login!(account)
      sleep(2)
      search = session.getSearch('alzheimer', 1)
      # search.each do |s|
        # puts s
      # end
      sleep(2)
      ads = session.getAds('cancer', 1)
    end
  end

end # end ProfilePopulator

ProfilePopulator.test