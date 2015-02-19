require_relative 'ProfilePopulator'
require_relative 'SearchParser'

SP = SearchParser.new

terms = ["Immigration", "Obama", "Abortion"]
locations = ["Tucson, AZ", "San Francisco, CA"]

Asearch =[{:txt=>"USCIS: Homepage", :url=>"http://www.uscis.gov/"},
		{:txt=>"Dealt Setback, Obama Puts Off Immigrant Plan - NYTimes.com", :url=>"http://www.nytimes.com/2015/02/18/us/obama-immigration-policy-halted-by-federal-judge-in-texas.html"},
		{:txt=>"Immigration - Wikipedia, the free encyclopedia", :url=>"http://en.wikipedia.org/wiki/Immigration"},
		{:txt=>"Immigration | The White House", :url=>"http://www.whitehouse.gov/issues/immigration"},
		{:txt=>"Texas judge's immigration rebuke may be hard to challenge ...", :url=>"http://www.reuters.com/article/2015/02/18/us-usa-immigration-courts-analysis-idUSKBN0LM02Y20150218"},
		{:txt=>"What the immigration ruling means - CNN.com", :url=>"http://www.cnn.com/2015/02/17/politics/immigration-ruling-obama/"},
		{:txt=>"Fix this hot, ugly immigration mess - CNN.com", :url=>"http://www.cnn.com/2015/02/17/opinion/navarro-immigration-injunction/"},
		{:txt=>"Why Republicans Might Want to Rethink Their Victory Lap ...", :url=>"http://abcnews.go.com/Politics/republicans-rethink-victory-lap-immigration/story?id=29049168"},
		{:txt=>"My Life as an Undocumented Immigrant", :url=>"http://www.nytimes.com/2011/06/26/magazine/my-life-as-an-undocumented-immigrant.html?pagewanted=all"},
		{:txt=>"Under-age and on the move", :url=>"http://www.economist.com/news/briefing/21605886-wave-unaccompanied-children-swamps-debate-over-immigration-under-age-and-move"},
		{:txt=>"In a crowded immigration court, seven minutes to ...", :url=>"http://www.washingtonpost.com/national/in-a-crowded-immigration-court-seven-minutes-to-decide-a-familys-future/2014/02/02/518c3e3e-8798-11e3-a5bd-844629433ba3_story.html"},
]

locations.each do |location|
	terms.each do |term|
		profile = ProfilePopulator.new
		signedin = profile.signIn()
		# if we could sign in

#/Users/ceciliareyes/Projects/magic2015/ProfilePopulator.rb:91:in `setSearchLocation': undefined method `click' for nil:NilClass (NoMethodError)
		if signedin
			# profile.setProfileLocation(location) # uncomment for G+ profile setting
			results = profile.searchTerms(term, location)
		end
		puts "---"
		puts SP.SearchComp(Asearch,results)
		puts "---"
		puts SP.SearchComp(results,Asearch)
		puts "---"
		puts results
		puts results.size
		## TODO None of these seem to work for getting a "clean slate" session
		#page.execute_script "window.close();"
		Capybara.reset_sessions!
		#Capybara.page.reset!
		#Capybara.page.current_window.close
	end
end

#s = SearchParser.new
#"#{puts terms.size
#}"puts terms.map{|t| t[:txt]}