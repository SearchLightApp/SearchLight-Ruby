
class LocalConfig
  def self.path_to_db_config
    return './Model/mongoid.yml'
  end
  def self.db_config_id
    return :cathy
  end
  def self.credentials
    return {:username => 'xray.app.1', :passwd => 'xraymagic10026'}
  end
end