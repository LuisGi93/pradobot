require 'sequel'
require_relative 'crear_tablas_bd'

db=Sequel.connect(ENV['URL_DATABASE'])
crear_tablas(db)
