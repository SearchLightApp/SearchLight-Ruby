require 'mongoid'
require_relative 'Searcher'
require_relative './Model/Query'
require_relative './Model/Result'

def readIntoArray(path)
	arr = []
	File.open(path, "r") do |f|
		f.each_line do |line|
			arr << line.strip
		end
	end
	return arr
end

# This file tells the program where to find the Database
path_to_db_config = './Model/mongoid.yml'

# Load the config file. Second argument specifies which configuration to use.
Mongoid.load!(path_to_db_config, :jumpingcrab)
#TODO: Set more sensible options in mongoid.yml (e.g. allow retries in case of connection failure)

# Reads the appropriate files and creates an array with them
locations = readIntoArray(ARGV[0])
searches = readIntoArray(ARGV[1])

# Credentials to use for login.
credentials = {:username => 'xray.app.1', :passwd => 'xraymagic10026'}

locations.each do |loc|
	STDOUT.write "+++++++++++++++++ Doing the relevant searches for location: " + loc + "\n"
	searches.each do |search_string|
		# Conduct a Google search using a headless browser.
		arr = Searcher.conductSearch(credentials, loc, search_string, 1, false)

		# Create Database object with the results from the search
		qq = Query.new(query: search_string, location: loc, results: [])
		# Store the results with the query
		arr.each_with_index do |elem , index|
		  res = Result.new(position: index, url: elem[:url] , txt: elem[:txt])
		  qq.results.push(res)
		end
		#Store Query in the database. Recursively stores Result items.
		qq.save
	end
end
		# Do *NOT* uncomment the next line
		# Query.collection.drop()