require 'mongoid'

class SearchResult
  include Mongoid::Document
  field :title,     type: String
  field :url,       type: String
  field :position,  type: String
end