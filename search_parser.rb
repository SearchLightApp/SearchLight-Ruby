require 'capybara'

class SearchParser
  include Capybara::DSL
  def initialize
    Capybara.default_driver = :selenium
  end
  def Query
    Capybara.visit 'http://plus.google.com'
    #Capybara.page.save_screenshot 'set_location.png'
    #expect(current_path).to eq(post_comments_path(post))
    puts current_url
    puts "hey"
  end
end

s = SearchParser.new

s.Query