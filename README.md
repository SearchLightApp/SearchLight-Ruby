SearchLight
=========

SearchLight is a tool for finding discrepencies in the web search results that different users see. Right now, SearchLight can compare what users in different locations would see when they make the same Google search. Soon, you will also be able to observe how differences in gender, name, age, or education could create imperceptible differences in how search algorithms tailor what they deliver to you.

## Dependencies
Firefox 34
Ruby 2.2.1
Selenium and Selenium-Webdriver gems
PhantomJS

gem install selenium selenium-webdriver
gem install mongoid

Not sure but maybe just in case. Gems that may be required
	rack-test
	rack

brew install phantomjs

## Databse Management
Start the database using:
		"mongod --dbpath=PATH"
Where PATH is the location of your database. If you don't have a database set up, mongo will initialize it at the given PATH.
The folder pointed to by PATH must already exist.

## To Run

	ruby TestB.rb