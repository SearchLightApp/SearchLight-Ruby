# encoding: utf-8
require 'capybara'
require 'capybara/poltergeist'

require 'active_support'
require 'active_support/core_ext/numeric'

require 'rspec/expectations'
# require 'capybara/rspec/matchers'
# require 'rspec'
# require 'capybara/rspec'


class Searcher
  include RSpec::Matchers
  include Capybara::DSL # used instead of manually starting session

  Capybara.default_wait_time = 5

  # use Capybara DSL
  # RSpec.configure do |config|
  #   config.include Capybara::DSL
  # end

  # DRIVERS
  # To inspect page console: page.driver.debug
  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end
  # headless
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1' ], :debug => false, timeout: 1.minute, :visible => false, js_errors: false)
  end
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app)
  end
   # interact with elements even if they're made invisible by CSS or JS
  Capybara.ignore_hidden_elements = false

  def initialize()
    Capybara.current_driver = :poltergeist_debug
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
    # get search results
    if @session.has_css?("#res")
      links = @session.all("#res h3 a")
    end
    # get ads
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
        expect(@session).to have_css("a[id='hdtb-tls']")
        @session.find("a[id='hdtb-tls']").click

        expect(@session).to have_css('div.hdtb-mn-hd')
        options = @session.all(:css, 'div.hdtb-mn-hd')

        expect(options.length).to be >= 2
        expect(@session).to have_content("Search tools")
        options[2].trigger('click')
        @session.save_screenshot 'img/clicked.png'

        tries = 0
        begin
          if tries < 10
            expect(@session).to have_css('div.hdtb-mn-hd')
            options[2].trigger('click')
          else
            puts "I give up!"
          end
        rescue
          puts "Waiting and retrying."
          sleep(3)
          tries += 1
          retry
        end

        # expect(@session).to have_css('lc-input')
        @session.save_screenshot 'img/lc input.png'
        @session.fill_in 'lc-input', :with => loc

        while @session.find('input[id="lc-input"]').value != loc do
          puts 'run me'
          @session.fill_in 'lc-input', :with => loc
        end

        expect(@session).to have_css('input[class="ksb mini"]')
        @session.save_screenshot 'img/fill.png'
        @session.find('input[class="ksb mini"]').trigger('click')
      # end
    # end
  end

# clear all cookies from the session and reset it
  def clean
    # @session.driver.browser.manage.delete_all_cookies # THIS THROWS A NASTY ERROR
    @session.reset!
    @session.driver.quit
  end

  # {:username => 'xray.app.1', :passwd => 'xraymagic10026'}
  def self.conductSearch(account, loc, query, page, login)
    pPop = self.new

    if login
      pPop.login!(account)
    end

    search = pPop.getSearch(query, loc, page)
    # puts search
    pPop.clean # reset sessions and delete cookies

    return search
  end

end # end ProfilePopulator

# Searcher.conductSearch({:username => 'xray.app.1', :passwd => 'xraymagic10026'}, 'Bozeman, MT', 'cows', 1, false)





