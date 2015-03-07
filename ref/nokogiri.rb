class GsearchAPI
  class AuthError < RuntimeError; end

  def self.test_accounts(accounts)
    File.open("check_accounts.results", "w+") do |f|
      i = 0;
      accounts.each do |account|
        i += 1
        api = self.new(account)
        status = api.test_account
        puts status
        f.write(status)
        if (i == 5) 
#          system("bin/change_ip")
          i = 0
        end
        sleep(2.seconds)
      end
    end
#    api = self.new(account)
  end

  def self.login_once_all_accounts(accounts)
    accounts.each do |account|
      api = self.new(account)
      status = api.test_account
      puts status
      sleep(2.seconds)
    end
  end

  def self.test(login, passwd, query, location, page_start, pages)
    acc = { login: login, passwd: passwd }
    api = self.new(acc)
    api.login
    ads = []
    pages.times do |i|
      ads = ads + api.get_ads_for(query, location, page_start + i)
    end
    ads
  end

  def self.test_get_searches(query, location, page)
    api = self.new({login: 'qlanxray200', passwd: 'qlanmdp200a'})
    api.login
    api.get_searches_for(query, location, page)
  end

  class CookieJar < Faraday::Middleware
    def initialize(app)
      super
      @cookies = {}
    end

    def pprint_meta(env, type)
     return if true

      case type
      when :request; color = :green; header = env[:request_headers]
      when :response; color = :red; header = env[:response_headers]
      end

      puts
      puts "request".send(color)
      puts "url ".send(color) + env[:url].to_s
      puts "verb ".send(color) + env[:method].to_s
      puts env[:body].to_s if type == :request && env[:method] == :post
      puts "headers ".send(color) + header.to_s
    end

    def call(env)
      set_meta(env)
      set_cookies(env)
      pprint_meta(env, :request)

      parse_cookies(env)
    end

    def cookies_for_host(env)
      @cookies ||= {}
    end

    def set_meta(env)
      env[:request_headers]['user-agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:32.0) Gecko/20100101 Firefox/32.0'
    end

    def set_cookies(env)
      env[:request_headers]["cookie"] = cookies_for_host(env).map { |k,v| "#{k}=#{v}"}.join("; ")
    end

    def parse_cookies(env)
      response = @app.call(env)
      response.on_complete do |e|
        pprint_meta(env, :response)

        raw_array = (e[:response_headers]['set-cookie'] || "").split(",")
        array = []
        skip = false
        raw_array.each do |item|
          unless skip
            array << item
          end
          if (item =~ /(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/)
            skip = true
          else
            skip = false
          end
        end

        cookies = array.select { |x| x =~ /=/ }.map { |x| x.split(';').first.strip.split('=', 2) }
        cookies_for_host(e).merge!(Hash[cookies])
      end
      response
    end

    Faraday.register_middleware :request, :cookie_jar => lambda { self }
  end

  attr_accessor :conn

  def initialize(account)
    @conn = Faraday.new do |faraday|
    #  faraday.request  :logger
      faraday.request  :url_encoded
    #  faraday.response :logger
      faraday.response :follow_redirects, :limit => 20
      faraday.request  :cookie_jar
      faraday.adapter  :net_http_persistent
    end
    account = account.attributes unless account.class.name == "Hash"
    @acc = Hash[account.map { |k,v| [k.to_s, v] }]
    @account = account
  end

  def handle_password_change(change_passw_html)
    n = Nokogiri::HTML(change_passw_html)
    time_stmp = n.css('form input[id="timeStmp"]').attr('value').to_s
    sec_tok = n.css('form input[id="secTok"]').attr('value').to_s
    passwd_num = /(\d+)$/.match(@acc['passwd'])
    raise AuthError if (time_stmp.empty? || sec_tok.empty? || !passwd_num)
    passwd_num = passwd_num[0].to_i + 1
    new_passwd = "kwdikosxray@!#{passwd_num}"
    response = @conn.post "https://accounts.google.com/ChangePassword", {
      "Passwd"      => new_passwd,
      "PasswdAgain" => new_passwd,
      "timeStmp"    => time_stmp,
      "secTok"      => sec_tok,
    }
    if (response.status != 200 || response.body =~ /"Please change your password"/)
      raise AuthError
    end
    @account.passwd = new_passwd
    @account.save!
    File.open("accounts_that_password_was_changed_#{Date.today.to_s}.txt", "a+") do |f|
      f.write("#{@account.login} #{@account.passwd}")
    end
  end

  def handle_verify_recovery_email(verify_recovery_email_html)
    n = Nokogiri::HTML(verify_recovery_email_html)
    checked_domains = n.css('form input[name="checkedDomains"]').attr('value').to_s
    check_connection = n.css('form input[name="checkConnection"]').attr('value').to_s
    pst_msg = n.css('form input[name="pstMsg"]').attr('value').to_s
    _utf8 = n.css('form input[name="_utf8"]').attr('value').to_s
    bgresponse = n.css('form input[name="bgresponse"]').attr('value').to_s
    response = @conn.post "https://accounts.google.com/LoginVerification", {
      "challengetype"   =>  "RecoveryEmailChallenge",
      "emailAnswer"     =>  @acc['recovery_email'],
      "checkedDomains"  => checked_domains,
      "checkConnection" => check_connection,
      "pstMsg"          => pst_msg,
      "_utf8"           => _utf8,
      "bgresponse"      => bgresponse,
    }
    raise AuthError if (response.status != 200 || response.body =~ /"Enter your recovery email address"/)
    return response
  end

  def handle_verify_city(verify_city_html)
    n = Nokogiri::HTML(verify_city_html)
    checked_domains = n.css('form input[name="checkedDomains"]').attr('value').to_s
    check_connection = n.css('form input[name="checkConnection"]').attr('value').to_s
    pst_msg = n.css('form input[name="pstMsg"]').attr('value').to_s
    _utf8 = n.css('form input[name="_utf8"]').attr('value').to_s
    bgresponse = n.css('form input[name="bgresponse"]').attr('value').to_s
    response = @conn.post "https://accounts.google.com/LoginVerification", {
      "challengetype"   =>  "MapChallenge",
      "lat"             =>  "40.7127837",
      "lng"             =>  "-74.00594130000002",
      "address"         =>  "New York, NY, United States",
      "checkedDomains"  => checked_domains,
      "checkConnection" => check_connection,
      "pstMsg"          => pst_msg,
      "_utf8"           => _utf8,
      "bgresponse"      => bgresponse,
    }
    raise AuthError if (response.status != 200 || response.body =~ /"Tell us the city you usually sign in from"/)
    return response
  end

  def handle_verify_multiple_methods(verify_multiple_methods_html)
    return handle_verify_recovery_email(verify_multiple_methods_html)
  end

  def test_account
    response = @conn.get "https://accounts.google.com/ServiceLogin"
    raise "oops" if response.status != 200

    n = Nokogiri::HTML(response.body)
    galx = n.css('form input[name="GALX"]').attr('value').to_s 
    response = @conn.post "https://accounts.google.com/ServiceLoginAuth", {
      "GALX"             => galx,
      "Email"            => @acc['login'],
      "Passwd"           => @acc['passwd'],
      "PersistentCookie" => "yes",
      "signIn" => "Sign in",
    }
    errors = Regexp.union("incorrect",
                          "Verify your identity",
                          "Verify it's you",
                          "suspicious",
                          "Your password was changed",)
    if (response.body =~ errors)
      #File.open("giannis/#{@acc['login']}.html", "w+") do |f|
      #  f.write(response.body.force_encoding('UTF-8'))
      #end
      return "#{@acc['login']}: " + "Unavailable!\n".red
    else
      return "#{@acc['login']}: " + "Available!\n".green
    end
  end

  def login
    response = @conn.get "https://accounts.google.com/ServiceLogin"
    raise "oops" if response.status != 200

    n = Nokogiri::HTML(response.body)
    galx = n.css('form input[name="GALX"]').attr('value').to_s 
    response = @conn.post "https://accounts.google.com/ServiceLoginAuth", {
      "GALX"             => galx,
      "Email"            => @acc['login'],
      "Passwd"           => @acc['passwd'],
      "PersistentCookie" => "yes",
      "signIn" => "Sign in",
    }
    errors = Regexp.union("incorrect",
                          "Your password was changed",)
    raise AuthError if response.body =~ errors
    if response.body.to_s =~ /"Enter your recovery email address"/
      response = handle_verify_recovery_email(response.body)
    elsif response.body =~ /"Tell us the city you usually sign in from"/
      response = handle_verify_city(response.body)
    end
    if response.body =~ /"Please change your password"/
      handle_password_change(response.body)
    end
    return self
  end

  def hashify(data)
    Hash[data.map { |v| [v[0], v[1..-1]] }]
  end

  # For test purpose
  def get_ads_for(query, location, page, save_results = false, username = "", iter = 0)
  # def get_ads_for(query, location, page)
    unless location.empty?
      google_sig = @conn.get("https://www.google.com/preferences").body
                       .scan(/input value=\"(.*?)\" name=\"sig\"/)[0][0]
      google_sig = URI.encode_www_form_component(google_sig)
      puts @conn.get("https://www.google.com/uul?muul=4_20&luul=#{location}&uulo=1&usg=#{google_sig}&hl=en").body.force_encoding('UTF-8')
    end
    query = URI.encode_www_form_component(query)
    page = 1 unless page.is_a? Integer
    query = "https://www.google.com/search?q=#{query}&start=#{10*(page-1)}"
    #query = "https://www.google.com/?gws_rd=ssl#q=#{query}&start=#{10*(page-1)}"
    wait = Random.rand(4).seconds
    status = ""
    while (status != "200")
      puts("waiting for #{(wait/60.0).round(2)} minutes") if wait
      sleep(wait)
      puts "query: #{query}"
      query_response = @conn.get(query)
      status = query_response.status.to_s
      puts "received #{status}"
      if status != "200"
        puts "/!\\".red + " Connection failed ".yellow + "/!\\".red
        if wait <= 60.seconds
          #Horrible horrible hack to change ip so that we do not have
          #to wait after getting blocked by gsearch
          #Sidekiq::Queue.all.each {|q| q.pause}

          system("bin/change_ip_macos.sh")
          sleep(30.seconds)
          # system("bin/change_ip")
          # sleep(2.minutes)
          #Sidekiq::Queue.all.each {|q| q.unpause}
          #wait = 40.minutes
        #elsif wait < 60.minutes
          #wait += wait
        end
      end
    end
    #File.open("search_time/#{username}_iter#{iter}_#{query.slice(/search\?q=.*&start=/)[9..100][0..-8]}_page#{page}.html", 'w+') { |f| f.write(query_response.body.force_encoding('UTF-8')) }
    n = Nokogiri::HTML(query_response.body)
    ads = []
    ad_nodes = n.css('li.ads-ad')
    ad_nodes.each do |ad_node|
      n = Nokogiri::HTML(ad_node.to_s)
      non_visible_url = n.css('h3 a[style="display:none"]').first['href']
      second_a_node = n.css('h3 a:not([style="display:none"])').first
      clickable_url = second_a_node['href']
      text_of_link = second_a_node.text
      non_clickable_url = n.css('div.ads-visurl cite').first.text
      description = n.css('div.ads-creative').first.text
      ad = {  :non_visible_url   => non_visible_url,
              :clickable_url     => clickable_url,
              :text_of_link      => text_of_link,
              :non_clickable_url => non_clickable_url,
               :description       => description,
              :page              => page }
      ads.push(ad)
    end
    if !save_results
      return ads
    end
    
    results = []
    result_nodes = n.css('li.g')
    result_nodes.each do |result_node|
      n = Nokogiri::HTML(result_node.to_s)
      title_node = n.css('h3 a').first
      next if title_node == nil
      text_of_link = title_node.text    
      clickable_url = title_node['href']
      non_clickable_url = n.css('cite[class="_Rm"]').text
      description = n.css('span[class="st"]').text
      result = {:clickable_url     => clickable_url,
                :text_of_link      => text_of_link,
                :non_clickable_url => non_clickable_url,
                :description       => description,
                :page              => page }
      results.push(result)
    end
    return ads, results
#    ads_regex = /
#      <li\sclass="ads-ad" #start of ad
#      .*?                 #skip over unuseful stuff
#      href="(.*?)"        #google internal link (maybe has id)
#      .*?                 #skip over unuseful stuff
#      <a\shref="(.*?)"    #actual ad link. Some times the same as 
#                          #the google internal link
#      .*?                 #skip over unuseful stuff
#      >(.*?)<\/a>         #get text of link
#      .*?                 #skip over unuseful stuff
#      <cite>(.*?)<\/cite> #visualUrl (the url right under the link.)
#      .*?                 #skip over unuseful stuff
#      <div\sclass="ads-creative">(.*?)<\/div>.*?<\/li>  #the text of the ad
#    /x
#    ads = query_response.body.force_encoding('UTF-8').scan(ads_regex)
#     #puts query_response.body
#    #puts ads
#    ads.map { |ad| { :non_visible_url => ad[0],
#                     :clickable_url => ad[1],
#                     :text_of_link => ActionView::Base.full_sanitizer.sanitize(ad[2]),
#                     :non_clickable_url => ActionView::Base.full_sanitizer.sanitize(ad[3]),
#                     :description => ActionView::Base.full_sanitizer.sanitize(ad[4]),
#                     :page => page,
#                    }
#    }
  rescue => e
    puts e.backtrace
    puts "[GsearchAPI] get_ads error"
    raise e
  end
end