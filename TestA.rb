require_relative 'ProfilePopulator'
require_relative 'SearchParser'

SP = SearchParser.new

$sign_me_in = false

terms = ["Immigration", "Abortion", "Loans", "Healthcare"]
locations = ["Minneapolis, MN", "Ypsilanti, MI", "Yarmouth, MA", "Miami, Florida", "El Paso, TX"]

def ProcessQuery(term, location,tries)
	# we try to do some stuff, and catch (almost all) errors with rescue
	global_variables
	begin
		profile = ProfilePopulator.new
		##Change false here to try signing in
		if $sign_me_in
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
		STDOUT.write "\n"
		STDOUT.write "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
		STDOUT.write e.to_s
		STDOUT.write "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
		STDOUT.write "\n"
		if (tries==0)
			STDOUT.flush
			STDERR.flush
			abort("I tried and I tried, but I kept failing")
			exit
		else
			ProcessQuery(term,location,tries-1)
		end
	end
	Capybara.reset_sessions!
	return results
end


locations.each do |q_location|
	STDOUT.write "\n\n$res['"+q_location+"']={}\n"
	terms.each do |q_term|
		results = ProcessQuery(q_term, q_location, 5)
		#STDOUT.write "----------------------------------------------------------------------------------------------------\n"
		if results.nil?
			STDOUT.write "No results!\n"
		else
			#STDOUT.write "\n"
			STDOUT.write "$res['"+q_location+"']['"+q_term+"']="
			STDOUT.write results
			STDOUT.write "\n"
			#STDOUT.write results.size
			#STDOUT.write "\n"
		end
		#STDOUT.write "----------------------------------------------------------------------------------------------------\n"
	end
end



#Capybara.page.reset!
#Capybara.page.current_window.close
#page.execute_script "window.close();"
