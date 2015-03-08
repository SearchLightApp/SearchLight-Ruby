require_relative 'ProfilePopulator'
require_relative 'SearchParser'

SP = SearchParser.new

$sign_me_in = false
$max_tries = 3

terms = ["Immigration", "Abortion", "Loans","Bank", "Healthcare", "Obama", "Marijuana", "Police", "Guns", "Hebdo", "Christian", "Jewish", "Divorce", "Obamacare","Israel","Palestine", "Brown"]
#locations = ['Birmingham, AL', 'Phoenix, AZ', 'San Francisco, CA', 'New York, NY', 'Birmingham, AL', 'Yarmouth, MA', 'Miami, FL', 'El Paso, TX', 'Minneapolis, MN', 'New Orleans, LA', 'Seattle,WA', 'Denver, CO', 'Ferguson, MO']
locations = ['Los Angeles, CA', 'Honolulu, HI', 'Boise, ID', 'Las Vegas, NV', 'Boston, MA', 'Austin, TX', 'Charlotte, NC', 'Salt Lake City, UT', 'St Louis, MO']

def ProcessQuery(term, location, tries)
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
		raise e
		STDOUT.write "("+($max_tries-tries+1).to_s+")"+ e.to_s + "\n"
		if (tries==0)
			STDOUT.flush
			STDERR.flush
			STDOUT.write("All tries failed\n")
			#exit
		else
			ProcessQuery(term,location,tries-1)
		end
	end
	Capybara.reset_sessions!
	return results
end


locations.each do |q_location|
	# STDOUT.write "\n\n$res['"+q_location+"']={}\n"
	terms.each do |q_term|
		results = ProcessQuery(q_term, q_location, $max_tries)
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
