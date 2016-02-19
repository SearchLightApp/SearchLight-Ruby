*~ SearchLight *~
=========

THIS VERSION OF SEARCHLIGHT IS NOW DEPRECATED. WE ARE PORTING THE APPLICATION TO PYTHON. STAY TUNED.

SearchLight is a tool for finding discrepencies in the web among search results for different users. Right now, SearchLight can compare what users in different locations would see when they make the same Google search.
Soon, you will also be able to observe how differences in gender, name, age, or education could create imperceptible differences in how search algorithms tailor what they deliver to you.

## Dependencies
* Firefox 34
* Ruby 2.2.1


## Gems to Install

* selenium 
	* then run selenium install
* selenium-webdriver
* mongoid
* launchy 
* capybara
* poltergeist

## Testing

* rspec-expectations
* rspec
* rspec-core

## Also...

	brew install phantomjs

## Troubleshooting

If you run into an undefined method `minute' for 1:Fixnum (NoMethodError)\, add the following to the top of Searcher.rb

	require 'active_support'
	require 'active_support/core_ext/numeric'

## Database Management
Start the database using:
		"mongod --dbpath=PATH"
Where PATH is the location of your database. If you don't have a database set up, mongo will initialize it at the given PATH.
The folder pointed to by PATH must already exist.

## To Run

	ruby Searchlight.rb file1 file2
		// file1 -> plain txt of locations, separated by newlines
		// file2 -> plain txt of search items, separated by newlines
	ruby searchComparison [query] ["location"] // compare results for [query] and its location with all other locations

## A note on Cron Jobs

	rvm cron setup

Running that will tell cron where to find any required gems
