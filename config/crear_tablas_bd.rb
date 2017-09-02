
def crear_tablas db

  db.create_table! :curso do
    primary_key :id_moodle, :type => 'integer'
    String      :nombre_curso
  end

  db.create_table! :chat_telegram do
    Integer :id_chat
    primary_key      :nombre_chat, :type => 'varchar(100)'
  end


  db.create_table! :chat_curso do
    foreign_key :nombre_chat_telegram, :chat_telegram, :key => 'nombre_chat', :type => 'varchar(100)',:on_delete => :cascade, :on_update => :cascade
    foreign_key :id_moodle_curso, :curso, :key => 'id_moodle', :on_delete => :cascade, :on_update => :cascade
    primary_key [:nombre_chat_telegram, :id_moodle_curso]
  end


  db.create_table! :usuario_telegram do
    String      :nombre_usuario
    primary_key :id_telegram, :type => 'integer'
  end


  db.create_table! :estudiante do
    foreign_key :id_telegram, :usuario_telegram, :on_delete => :cascade, :on_update => :cascade, :primary_key => true
  end

  db.create_table! :profesor do
    foreign_key :id_telegram, :usuario_telegram, :on_delete => :cascade, :on_update => :cascade, :primary_key => true
  end

  db.create_table! :estudiante_curso do
    foreign_key :id_estudiante, :estudiante, :on_delete => :cascade, :on_update => :cascade
    foreign_key :id_moodle_curso, :curso, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_estudiante, :id_moodle_curso]
  end

  db.create_table! :profesor_curso do
    foreign_key :id_profesor, :profesor, :on_delete => :cascade, :on_update => :cascade
    foreign_key :id_moodle_curso, :curso, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_profesor, :id_moodle_curso]
  end


  db.create_table! :usuarios_moodle do
    Column     :email, :type => 'varchar(100)', :unique  => true
    foreign_key :id_telegram, :usuario_telegram, :on_delete => :cascade, :on_update => :cascade, :primary_key => true
  end

  db.create_table! :datos_moodle do
    foreign_key :email, :usuarios_moodle, :key =>  'email', :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    Integer :id_moodle
    String      :token
  end



  db.create_table! :tutoria do
    foreign_key :id_profesor, :profesor, :key => 'id_telegram', :on_delete => :cascade, :on_update => :cascade
    Time :dia_semana_hora
    primary_key [:dia_semana_hora, :id_profesor]
  end

  db.create_table! :peticion_tutoria do
    Integer :id_profesor
    foreign_key :id_estudiante, :estudiante, :on_delete => :cascade, :on_update => :cascade
    Time :dia_semana_hora
    Time    :hora_solicitud
    String    :estado
    primary_key [:id_profesor, :id_estudiante, :dia_semana_hora]
    foreign_key [:dia_semana_hora, :id_profesor], :tutoria, :on_delete => :cascade, :on_update => :cascade
  end



  db.create_table! :dudas do
    foreign_key :id_usuario_duda, :usuarios_moodle, :key => 'id_telegram', :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    Column     :contenido_duda, :type => 'varchar(1000)'
    primary_key [:id_usuario_duda, :contenido_duda]
  end

  db.create_table! :dudas_curso do
    Integer :id_usuario_duda
    Column     :contenido_duda, :type => 'varchar(1000)'
    foreign_key :id_moodle_curso, :curso, :key => 'id_moodle', :on_delete => :cascade, :on_update => :cascade
    foreign_key [:id_usuario_duda, :contenido_duda], :dudas, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_usuario_duda, :contenido_duda, :id_moodle_curso]
  end



  db.create_table! :dudas_resueltas do
    Integer :id_usuario_duda
    Column     :contenido_duda, :type => 'varchar(1000)'
    foreign_key [:id_usuario_duda, :contenido_duda], :dudas, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_usuario_duda, :contenido_duda]
  end



  db.create_table! :respuestas do
    foreign_key :id_usuario_respuesta, :usuarios_moodle , :key => 'id_telegram', :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    Column     :contenido_respuesta, :type => 'varchar(1000)'
    primary_key [:id_usuario_respuesta, :contenido_respuesta]
  end

  db.create_table! :respuesta_duda do
    Integer :id_usuario_duda
    Column     :contenido_duda, :type => 'varchar(1000)'
    Integer :id_usuario_respuesta
    Column     :contenido_respuesta, :type => 'varchar(1000)'
    foreign_key [:id_usuario_duda, :contenido_duda], :dudas, :on_delete => :cascade, :on_update => :cascade
    foreign_key [:id_usuario_respuesta, :contenido_respuesta], :respuestas, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_usuario_respuesta, :contenido_respuesta, :id_usuario_duda, :contenido_duda]
  end


  db.create_table! :respuesta_resuelve_duda do
    Integer :id_usuario_duda
    Column     :contenido_duda, :type => 'varchar(1000)'
    Integer :id_usuario_respuesta
    Column     :contenido_respuesta, :type => 'varchar(1000)'
    foreign_key [:id_usuario_duda, :contenido_duda], :dudas, :on_delete => :cascade, :on_update => :cascade
    foreign_key [:id_usuario_respuesta, :contenido_respuesta], :respuestas, :on_delete => :cascade, :on_update => :cascade
    primary_key [:id_usuario_respuesta, :contenido_respuesta, :id_usuario_duda, :contenido_duda]
  end





end
