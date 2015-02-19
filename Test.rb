require_relative 'ProfilePopulator'
require_relative 'SearchParser'

SP = SearchParser.new

terms = ["Immigration", "Obama", "Abortion"]
locations = ["Tucson, AZ", "San Francisco, CA"]

locations.each do |location|
	terms.each do |term|
		profile = ProfilePopulator.new

    signedin = profile.signIn()

			# if we could sign in
		if signedin
			profile.setProfileLocation(location) # uncomment for G+ profile setting
			results = profile.searchTerms(term, location)
		end
		puts results
		puts results.size
		puts "___________________________________________"
		## TODO None of these seem to work for getting a "clean slate" session
		Capybara.reset_sessions!
	end
end

#Capybara.page.reset!
#Capybara.page.current_window.close
#page.execute_script "window.close();"
