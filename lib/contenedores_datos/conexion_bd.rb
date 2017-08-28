require 'sequel'

class ConexionBD
  @@db = Sequel.connect(ENV['URL_DATABASE'])
end
