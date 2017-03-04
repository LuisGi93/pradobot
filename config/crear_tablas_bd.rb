require 'sequel'


db = Sequel.connect(ENV['URL_DATABASE'])

db.create_table! :usuarios_moodle do
  primary_key :id
  String      :nombre,      :size => 255
  String      :apellidos,   :size => 510
  String      :email,       :size => 765
  String      :contraseña,    :size => 255
  String      :tipo_usuario
  DateTime    :fecha_alta
  Integer     :id_moodle
end

db.create_table! :usuarios_telegram do
  Integer     :id_telegram
  String      :email,       :size => 765
  primary_key :id
  String      :tipo_usuario             #duplicado pero agiliza la consulta del tipo de usuario cuando llega mensaje al bot
  DateTime    :fecha_alta
end


db.create_table! :tokens_tipo_usuario_moodle do
  String      :tipo_usuario
  String      :nombre_rol_moodle
  String      :id_rol_moodle
  String      :token_moodle
end

