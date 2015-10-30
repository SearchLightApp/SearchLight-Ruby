#each individual item from a search Result
class Result
  include Mongoid::Document
  field :position,  type: Integer
  field :txt,       type: String
  field :url,       type: String
  embedded_in :query


  def identifier
    #return [self.adtxt, ""]
    return [self.txt, self.url]
  end
end