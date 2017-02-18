require 'sequel'

db = Sequel.connect(ENV['URL_DATABASE'], :user=>ENV['USER_DATABASE'], :password=>ENV['PASSW_DATABASE'])


db.create_table! :usuarios_moodle do
  primary_key :id
  String      :nombre,      :size => 255
  String      :apellidos,   :size => 510
  String      :email,       :size => 765
  String      :tipo_usuario
  DateTime    :fecha_alta
  String      :token_moodle
  Integer     :id_moodle
end

db.create_table! :usuarios_telegram do
  Integer     :id_telegram
  Integer     :id_moodle
  primary_key :id
  String      :nombre_usuario,  :size => 255
  DateTime    :fecha_alta
end

