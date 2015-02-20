require_relative 'ProfilePopulator'
require_relative 'SearchParser'

SP = SearchParser.new




terms = ["Immigration", "Obama", "Abortion"]
locations = ["Tucson, AZ", "San Francisco, CA"]

def ProcessQuery(term, location,tries)
	# we try to do some stuff, and catch (almost all) errors with rescue
	begin
		profile = ProfilePopulator.new
		##Change false here to try signing in
		if false
			signedin = profile.signIn()
			# if we could sign in
			if signedin
				profile.setProfileLocation(location) # uncomment for G+ profile setting
			else
				raise "Failed to signin"
			end
		end

		results = profile.searchTerms(term, location)
	# Here we catch errors, print them and try again
	rescue StandardError => e
		puts ""
		puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		puts e.to_s
		puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		puts ""
		if (tries==0)
			STDOUT.flush
			STDERR.flush
			abort("I tried and I tried, but I kept failing")
			exit
		else
			ProcessQuery(term,location,tries-1)
		end
	ensure
		Capybara.reset_sessions! #TODO This was broken until you commented out an assertion in session.rb
		return results
	end
end


locations.each do |q_location|
	terms.each do |q_term|
		results = ProcessQuery(q_term, q_location, 5)
		puts "----------------------------------------------------------------------------------------------------"
		puts results
		puts results.size
		puts "----------------------------------------------------------------------------------------------------"
	end
end



#Capybara.page.reset!
#Capybara.page.current_window.close
#page.execute_script "window.close();"
