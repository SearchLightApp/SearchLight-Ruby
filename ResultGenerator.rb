require_relative 'Searcher'
require_relative 'SearchComparison'

SP = SearchComparison.new

queries = ["Immigration", "Healthcare"]
locations = ["Minneapolis, MN", "Ypsilanti, MI"]

def ProcessQuery(query, loc, tries)
	# we try to do some stuff, and catch (almost all) errors with rescue
	global_variables
	begin
		# hard code account, dont login
		results = Searcher.conductSearch({:username => 'xray.app.1', :passwd => 'xrayalltheasses'}, loc, query, 1, false)

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
			ProcessQuery(query,loc,tries-1)
		end
	end
	return results
end

# def test
	r = {}
	locations.each do |loc|
		location = {}
		queries.each do |q|
			results = ProcessQuery(q, loc, 5)
			# puts results
			if results.nil?
				STDOUT.write "No results for loc:"+loc+" and query:"+q+"\n"
			else
				location[q]=results
			end
		end
		r[loc]=location
	end
	puts(r['Minneapolis, MN']['Healthcare']) # pretty prints the results
# end
