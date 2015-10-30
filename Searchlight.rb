require 'mongoid'
require_relative 'Searcher'
require_relative './Model/Query'
require_relative './Model/Result'
require_relative './Model/Ad'
require_relative './LocalConfig'

class Searchlight
	def self.readIntoArray(path)
		arr = []
		File.open(path, "r") do |f|
			f.each_line do |line|
				arr << line.strip
			end
		end
		return arr
	end

	def self.main()
		if ARGV.length != 3
			puts "Please feed me two files and a number like \"ruby Searchlight.rb [locations] [searches] [# of queries]\""
			exit
		elsif ARGV[2].to_i == 0
			puts "I don't understand how many queries I should run"
			exit
		else
			log = Logger.new("| tee ./log/error.log", 'weekly') # note the pipe ( '|' ), now log.info will log to both STDOUT and test.log
			Mongoid.load!(LocalConfig.path_to_db_config, LocalConfig.db_config_id)

			number_of_queries = ARGV[2].to_s

			# Reads the appropriate files and creates an array with them
			locations = readIntoArray(ARGV[0])
			searches = readIntoArray(ARGV[1])

			number_of_queries.times do |i|
				loc = locations.sample
				search_string = searches.sample
				puts "("+n.to_s+"/"number_of_queries.to_s")"
				begin
					run(loc, search_string)
				rescue
					log.info "\nFailed:\n\tLOC: " + loc + "\n\tQRY: " + search_string
					exit
				end
			end
		end
	end

	def self.run(loc, search_string)
		#TODO: Set more sensible options in mongoid.yml (e.g. allow retries in case of connection failure)

		# Conduct a Google search using a headless browser.
		search_output = Searcher.conductSearch(LocalConfig.credentials, loc, search_string, 1, false)
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
		# Do *NOT* uncomment the next line
		# Query.collection.drop()
	end
end



# use her for good, never evil
Searchlight.main()
