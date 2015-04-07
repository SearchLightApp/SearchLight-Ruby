require 'mongoid'

#Mongoid.load!('/Users/maxtucker/Documents/Probabilities/Confidence/magic2015/magic/config/mongoid.yml', :development)
#Mongoid.load!('mongoid.yml', :development)

class Person
  include Mongoid::Document
  field :first_name,  type: String
  field :middle_name, type: String
  field :last_name,   type: String
end

me = Person.new(first_name: "Max", middle_name: "Lee", last_name: "Tucker")

me.save()

print Person.first


#Clean up

#Person.collection.drop()

#Capybara.page.reset!
#Capybara.page.current_window.close
#page.execute_script "window.close();"