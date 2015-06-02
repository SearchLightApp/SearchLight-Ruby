require 'mongoid'

path_to_db_config = './Model/mongoid.yml'
Mongoid.load!(path_to_db_config, :development)

puts Dir.pwd

class Person
  include Mongoid::Document
  field :first_name,  type: String
  field :middle_name, type: String
  field :last_name,   type: String
end

me = Person.new(first_name: "Max", middle_name: "Lee", last_name: "Tucker")

me.save()

print Person.first

Person.collection.drop()

#Capybara.page.reset!
#Capybara.page.current_window.close
#page.execute_script "window.close();"