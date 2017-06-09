require 'sequel'
require_relative '../lib/moodle_api'
require_relative 'crear_tablas_bd'

db=Sequel.connect(ENV['URL_DATABASE'])
=begin
params={'field' => 'email', 'values[0]'  => 'bot_telegram@bot_telegram.com'} #necesario que el bot este creado en moodle con este email
moodle=Moodle.new(ENV['TOKEN_MANAGER_MOODLE'])
id_moodle_bot=moodle.api('core_user_get_users_by_field', params )[0]['id']

db.from(:usuarios_bot).insert(:email => 'bot_telegram@bot_telegram.com',  :rol_usuario => 'estudiante_bot', :fecha_alta =>  Time.now, :id_moodle => id_moodle_bot,
                               :token_moodle => ENV['TOKEN_BOT_MOODLE'])

db.from(:usuarios_bot).insert(:email => 'bot_telegram@bot_telegram.com',  :rol_usuario => 'estudiante_bot', :fecha_alta =>  Time.now, :id_moodle => id_moodle_bot,
                              :token_moodle => ENV['TOKEN_BOT_MOODLE'])

=end
crear_tablas(db)