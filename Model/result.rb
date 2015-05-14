#Each individual item from a search result
class Result
  include Mongoid::Document
  field :position,  type: Integer
  field :txt,       type: String
  field :url,       type: String
  embedded_in :query
end