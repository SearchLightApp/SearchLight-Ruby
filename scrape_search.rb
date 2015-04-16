require 'rubygems'
require 'nokogiri'
require 'open-uri'

### TEST FILE
html = Nokogiri::HTML(open("results_kathmandu.html"))

### DO SEARCH
query = "immigrants"
page  = open "http://www.google.com/search?num=100&q=" + query
html  = Nokogiri::HTML page

# puts html.css('div.rc')[1]

### SCRAPE LINKS
# html.search("cite").each do |cite| # also "cite._Rm"
#   puts cite.inner_text
# end

### SCRAPE NEWS RESULTS (??)
# html.search("a._Dk").each do |a|
#   puts a.inner_text
# end

### SCRAPE RESULTS BY XPATH
html.xpath('//h3[@class="r"]').each do |h3|
  puts h3.content
end