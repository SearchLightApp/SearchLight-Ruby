require 'rubygems'
require 'mechanize'
require 'logger'

#Mechanize.log = Logger.new $stderr
agent = Mechanize.new
page = agent.get('http://google.com/')

sign_in = page.links_with(:text => 'Sign in')[0].click

sign_in_form = sign_in.forms[0]

sign_in_form.fields[5].value = "xray.app.6"
sign_in_form.fields[6].value = "xraymyass"
# Unfortunately this is just javascript
# out = agent.submit sign_in_form

s_page = agent.get "http://www.google.com/"
search_form = s_page.form_with :name => "f"
search_form.field_with(:name => "q").value = "haircut"
res= agent.submit search_form
puts res.body

