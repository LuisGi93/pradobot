require 'net/http'
require 'open-uri'
require 'json'

class Moodle

  def initialize(user_token)
    @moodle_url="http://" + ENV['MOODLE_HOST'] + "/webservice/rest/server.php"
    puts 'Mi url es  ' + @moodle_url
    @user_token=user_token
  end



  def api (function, params=nil)
    uri = URI(@moodle_url)
    if params
      arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}.merge(params)
    else
      arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}
    end
    uri.query = URI.encode_www_form(arguments)
    page = Net::HTTP.get(uri)
    JSON.parse(page)
  end

  def obtener_token (username, password, service)
    uri = URI("http://" + ENV['MOODLE_HOST'] + "/login/token.php")
    arguments= { :username  => username , :password => password, :service  => service}
    uri.query = URI.encode_www_form(arguments)
    puts uri.to_s
    page = Net::HTTP.get(uri)
    JSON.parse(page)
  end

end

