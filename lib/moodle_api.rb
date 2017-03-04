require 'net/http'
require 'open-uri'
require 'json'

class Moodle

  def initialize(user_token)
    @moodle_url="http://" + ENV['MOODLE_HOST'] + "/webservice/rest/server.php"
    puts 'Mi url es  ' + @moodle_url
    @user_token=user_token
  end



  def api (function, arguments)
    uri = URI(@moodle_url)
    arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}.merge(arguments)
    uri.query = URI.encode_www_form(arguments)
    page = Net::HTTP.get(uri)
    JSON.parse(page)
  end

end
