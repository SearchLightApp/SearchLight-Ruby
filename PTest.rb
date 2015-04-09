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


  def initialize()
    # Capybara.default_driver = :selenium
    Capybara.current_driver = :poltergeist_debug

    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X)' } # spoof user

    Capybara.run_server = false
  end

  attr_accessor :session


  def test

    #@session.visit('https://accounts.google.com/ServiceLogin?hl=en')
    puts "hey"
    @session.visit('https://www.google.com')
    sleep(2)
    puts @session.body
    #page.blah
    #puts @session.page.body

  end

end # end ProfilePopulator

pp = ProfilePopulator.new
pp.test