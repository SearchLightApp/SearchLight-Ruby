require 'rubygems'
require 'mechanize'
require 'logger'

agent = Mechanize.new
page = agent.get('http://google.com/')

# sign into account
sign_in = page.links_with(:text => 'Sign in')[0].click

#pp sign_in

sif = sign_in.forms[0]
sif.field_with(:name => "Email").value = "xray.app.6"
puts sif.methods - Object.methods
puts "_________________________________________"
sif.fields[5].value = "xray.app.6"
sif.fields[6].value = "xraymyass"
out = agent.submit sif

# search and get new results
newpage = agent.get "http://www.google.com/"
search_form = page.form_with :name => "f"
search_form.field_with(:name => "q").value = "haircut"
res= agent.submit search_form
puts res.links
