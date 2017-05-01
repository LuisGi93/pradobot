require 'sequel'
require_relative 'usuario'


class ConexionBD
  @@db=Sequel.connect(ENV['URL_DATABASE'])
end