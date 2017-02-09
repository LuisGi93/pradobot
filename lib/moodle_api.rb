require 'net/http'
require 'open-uri'

class Moodle

  def initialize(url_moodle, user_token)
    @moodle_url="http://" + url_moodle + "/webservice/rest/server.php"
    @user_token=user_token
  end



  def api (function, arguments)
    uri = URI(@moodle_url)
    arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}.merge(arguments)
    uri.query = URI.encode_www_form(arguments)
    page = Net::HTTP.get(uri)
  end

end