require 'sequel'

#Clase de la que heredan todas aquellas que quieran utilizar la base de datos de la aplicación 
class ConexionBD
  @@db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
end
