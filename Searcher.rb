# encoding: utf-8
require 'capybara'
require 'capybara/poltergeist'

class Searcher
  include Capybara::DSL # used instead of manually starting session

  # DRIVERS
  # To inspect page console: page.driver.debug
  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end
  # headless
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'], :debug => false, timeout: 1.minute, :visible => false)
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

# before searching for the given string, sets the Location of search and then returns a dict w each result
  def getSearch(string, loc, page)
    query = "https://www.google.com/search?q=#{string.gsub(/ /, '+')}&start=#{10*(page-1)}"
    @session.visit(query)

    setSearchLocation(loc)
    sleep(2) # wait for location setting to kick in
    if @session.has_css?("#res")
      links = @session.all("#res h3 a")
    end
    if @session.has_css?(".ads-ad")
      adlinks = @session.all(".ads-ad h3 a")
    end
    storelinks =  links.map{|elem| {txt: elem.text, url: elem[:href]}}
    if adlinks.nil?
      storeads = []
    else
      storeads = adlinks.map{|elem| {adtxt: elem.text, adurl: elem[:href]}}
    end
    return {links: storelinks, ads: storeads};
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

# changes the location on the gsearch page
  def setSearchLocation(loc)
    # @session.save_and_open_screenshot('img/searchA.png')
    # puts @session.body

    # first turn off personal results
    # @session.find('a[id="abar_ps_off"]').click

    sleep(3) # wait so we can get the 'set Location' option
    @session.find("a[id='hdtb-tls']").click
    options = @session.all(:css, 'div.hdtb-mn-hd')
    # @session.save_and_open_screenshot('img/searchA.png')
    # puts options.length # check length of options

    sleep(2)
    options = @session.all(:css, 'div.hdtb-mn-hd')
    options[2].click
    sleep(3) # wait so we can get a box to fill
    @session.save_screenshot 'img/lc input.png'
    @session.fill_in 'lc-input', :with => loc
    @session.save_screenshot 'img/fill.png'
    @session.find('input[class="ksb mini"]').click
  end

# clear all cookies from the session and reset it
  def clean
    # @session.driver.browser.manage.delete_all_cookies # THIS THROWS A NASTY ERROR
    @session.reset!
  end

  # {:username => 'xray.app.1', :passwd => 'xraymagic10026'}
  def self.conductSearch(account, loc, query, page, login)
    pPop = self.new

    if login
      pPop.login!(account)
    end

    search = pPop.getSearch(query, loc, page)
    pPop.clean # reset sessions and delete cookies

    return search
  end

end # end ProfilePopulator