class GsearchLogin
  include Capybara::DSL

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)#, :args => ['--incognito'])
    # require 'selenium/webdriver'
    # Selenium::WebDriver::Firefox::Binary.path = "/opt/firefox/firefox"
    # Capybara::Selenium::Driver.new(app, :browser => :firefox)
  end

  attr_accessor :gsearch
  
  def initialize
    # Capybara.default_wait_time = 30
    @gsearch = Capybara::Session.new(:selenium)
    Capybara.run_server = false
    Capybara.default_driver = :selenium
    Capybara.app_host = 'http://www.google.com'
  end

  def login!(account, link = 'https://accounts.google.com/ServiceLogin?hl=en')
    @gsearch.visit(link)
    @gsearch.within("form#gaia_loginform") do
      @gsearch.fill_in 'Email', :with => (account[:login] || account["login"])
      @gsearch.fill_in 'Passwd', :with => (account[:passwd] || account["passwd"])
    end
      @gsearch.uncheck 'Stay signed in'
      @gsearch.click_on 'Sign in'
  end

  def get_gsearch_ground_truth(string, page)
    query = "https://www.google.com/search?q=#{string.gsub(/ /, '+')}&start=#{10*(page-1)}"
    @gsearch.visit(query)
    sleep(1)

    begin
      @gsearch.find(:xpath, '//*[@id="mbEnd"]/h2/span[2]/a').click
    rescue
      begin
        @gsearch.find(:xpath, '//*[@id="tads"]/h2/span/a').click
      rescue
        begin
        @gsearch.find(:xpath, '//*[@id="tadsb"]/h2/span/a').click
        rescue
          return nil
        end
      end
    end
    sleep(1)
    @gsearch.find(:xpath, '//*[@id="abbl"]/div/div[2]/a').click
    sleep(1)
    
    ads_list = @gsearch.all('div.HK').map{|a| a.all('div.eB')}
    ads = []
    ads_list.each do |ad|
      ad_info = ad.first.all('div').map{|e| e.text}
      ad_text = ad_info[1]
      ad_url = ad_info[2]
      ad_description = ad_info[3..ad_info.count].join(' ')
      ad_truth = ad.last.all('div').map{|e| e.text}
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

  def self.gsearch_time_exp(name, interval)
    exp = GsearchExperiment.create({
      :name => name,
      :s_perc_a => 1,
      :account_number => 1,
      :type => "gsearch",
      :has_master => true,
      })
    exp.searches = ['breast cancer', 'cancer']
    exp.save

    master_acc_id = ""
    Mongoid.with_tenant(name) {
      GsearchGoogleAccount.create({ :first_name => "Qing",
                                    :last_name  => "Lan",
                                    :gmail      => "qlanxray111@gmail.com",
                                    :login      => "qlanxray111",
                                    :passwd     => "qlanmdp111a",
                                    :bd         => 16,
                                    :bm         => "02",
                                    :by         => "1992",
      })
      master_acc_id = GsearchGoogleAccount.first.id.to_s
    }
  
    exp = GsearchExperiment.where(name: name).first
    exp.master_account = master_acc_id
    exp.save
    exp.assign_searches

    session = self.new
    Mongoid.with_tenant(name) {
      account = GsearchGoogleAccount.first
      session.login!(account)
      exp.searches.each_with_index do |kw, i|
        sleep(interval.seconds) if i > 0
        ads = session.get_gsearch_ground_truth(kw, 1)
        search_snapshot = SearchSnapshot.create!({:account  => account,
                                                  :iteration => 0,
                                                  :query     => kw,
                                                  :location  => "",})
        ads.each do |ad|
          ad.merge!({ :account   => account,
                      :iteration => 0,
                      :context   => search_snapshot, })
          GsearchAdSnapshot.create!(ad)
        end
      end
    }

  end


  def clean
    @gsearch.driver.browser.manage.delete_all_cookies
    @gsearch.reset!
  end

  def self.test
    session = self.new
    account = {:login => 'qlanxray111', :passwd => 'qlanmdp111a'}

    session.login!(account)
    sleep(2)
    session.get_gsearch_ground_truth('alzheimer', 1)
    sleep(2)
    session.get_gsearch_ground_truth('retirement home', 1)
  end
end