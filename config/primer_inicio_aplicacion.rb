require 'sequel'
require_relative '../lib/moodle_api'


params={'criteria[0][key]' => 'email', 'criteria[0][value]'  => 'manager@manager.com'}
moodle=Moodle.new(ENV['TOKEN_MANAGER_MOODLE'])
id=moodle.api('core_user_get_users ', params )['users'][0]['id']

db=Sequel.connect(ENV['URL_DATABASE'])

db.from(:usuarios_moodle).insert(:nombre => 'manager', :apellidos => 'manager', :email => 'manager@manager.com',
                                   :tipo_usuario => 'administrador', :fecha_alta =>  Time.now,
                                   :id_moodle => 5, :contraseña => ENV['PASS']


)

db.from(:usuarios_telegram).insert(:id_telegram => ENV['TELEGRAM_ID'],  :email => 'manager@manager.com',
                                  :tipo_usuario => 'administrador', :fecha_alta =>  Time.now


)

db.from(:tokens_tipo_usuario_moodle ).insert(:tipo_usuario => 'administrador', :token_moodle =>  ENV['TOKEN_MANAGER_MOODLE']


)
db.from(:tokens_tipo_usuario_moodle ).insert(:tipo_usuario => 'profesor', :token_moodle =>  ENV['TOKEN_PROFESOR_MOODLE']


)
db.from(:tokens_tipo_usuario_moodle ).insert(:tipo_usuario => 'estudiante', :token_moodle =>  ENV['TOKEN_ESTUDIANTE_MOODLE']


)