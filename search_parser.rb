require 'capybara'

#
# Import
#

class SearchParser
  include Capybara::DSL
  def initialize
    Capybara.default_driver = :selenium
  end
  def Query
    Capybara.visit 'https://google.com'
    #Capybara.page.save_screenshot 'set_location.png'
    #expect(current_path).to eq(post_comments_path(post))
    #uri = URI.parse(current_url)
    #"#{uri.path}?#{uri.query}".should == people_path(:search => 'name')
    puts current_url
    puts current_path
    fill_in 'q', :with => "immigration"
    #click_on 'signIn'
    page.save_screenshot 'set_location.png'
  end
end

s = SearchParser.new

s.Query