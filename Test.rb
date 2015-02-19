require_relative 'ProfilePopulator'
require_relative 'SearchParser'


profile = ProfilePopulator.new
terms = ARGV[0]
location = ARGV[1]
signedin = profile.signIn()
# if we could sign in

if signedin
  # setProfileLocation(location) # uncomment for G+ profile setting
  profile.searchTerms(terms, location)

end