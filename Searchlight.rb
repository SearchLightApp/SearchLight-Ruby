require 'mongoid'
require_relative 'Searcher'
require_relative './Model/Query'
require_relative './Model/Result'
require_relative './Model/Ad'

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

#locations = ["Miami", "Boston", "New Jersey", "Austin, TX"] #, "Boston"]
#searches = ["police"]   #, "Muslims"]

# Credentials to use for login.
credentials = {:username => 'xray.app.1', :passwd => 'xraymagic10026'}

locations.each do |loc|
	STDOUT.write "+++++++++++++++++ Doing the relevant searches for location: " + loc + "\n"
	searches.each do |search_string|
    STDOUT.write "+++++++++++++++++ >>> " + search_string + "\n"
		# Conduct a Google search using a headless browser.
    search_output = Searcher.conductSearch(credentials, loc, search_string, 1, false)
		links_arr = search_output[:links]
    ads_arr = search_output[:ads]

		# Create Database object with the results from the search
		qq = Query.new(query: search_string, location: loc, results: [])

		# Store the results with the query
		links_arr.each_with_index do |elem , index|
		  res = Result.new(position: index, url: elem[:url] , txt: elem[:txt])
		  qq.results.push(res)
    end

    # Also store the ads
    ads_arr.each_with_index do |elem , index|
      res = Ad.new(position: index, adurl: elem[:adurl] , adtxt: elem[:adtxt])
      qq.ads.push(res)
    end

		#Store Query in the database. Recursively stores Result and Ad items.
		qq.save
	end
end
		# Do *NOT* uncomment the next line
		# Query.collection.drop()