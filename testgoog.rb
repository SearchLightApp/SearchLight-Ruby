require 'rubygems'
require 'mechanize'
require 'logger'

#Mechanize.log = Logger.new $stderr
agent = Mechanize.new
page = agent.get('http://google.com/')

sign_in = page.links_with(:text => 'Sign in')[0].click

#pp sign_in

#sif = sign_in.forms[0]
#sif.field_with(:name => "Email").value = "xray.app.6"
#puts sif.methods - Object.methods
#puts "_________________________________________"
sif.fields[5].value = "maxltucker@gmail.com"
sif.fields[6].value = "M9vMv6zKzPp8"
out = agent.submit sif

newpage = agent.get "http://www.google.com/"
search_form = page.form_with :name => "f"
search_form.field_with(:name => "q").value = "haircut"
res= agent.submit search_form
puts res.links

