require 'sequel'
require_relative 'crear_tablas_bd'

db=Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
crear_tablas(db)
