require 'mongoid'

#A full set of search results
class Query
  include Mongoid::Document
  include Mongoid::Timestamps::Created #automatically adds a timestamp upon creation
  field :query,    type: String
  field :location, type: String
  embeds_many :ads,     cascade_callbacks: true
  embeds_many :results, cascade_callbacks: true #second argument makes it so saving Query also saves results
end