
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
    Column    :email,  :type => 'varchar(100)', :unique  => true
  end

  db.create_table! :profesor do
    foreign_key :id_telegram, :usuario_telegram, :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    Column     :email, :type => 'varchar(100)', :unique  => true
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


  db.create_table! :admin do
    foreign_key :id_telegram, :usuario_telegram, :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    String      :nombre_usuario

  end


  db.create_table! :estudiante_moodle do
    foreign_key :email, :estudiante, :key =>  'email', :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    Integer :id_moodle
    String      :token
  end

  db.create_table! :profesor_moodle do
    foreign_key :email, :profesor, :key =>  'email', :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    Integer :id_moodle
    String      :token
  end


  db.create_table! :dudas do
    foreign_key :id_estudiante, :estudiante, :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    foreign_key :id_moodle_curso, :curso, :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    String      :contenido
    primary_key [:id_estudiante, :contenido]
  end



  db.create_table! :tutoria do
    foreign_key :id_profesor, :profesor, :key => 'id_telegram', :on_delete => :cascade, :on_update => :cascade
    String :dia_semana
    Time :hora
    primary_key [:dia_semana, :hora, :id_profesor]
  end

  db.create_table! :peticion_tutoria do
    Integer :id_profesor
    foreign_key :id_estudiante, :estudiante, :on_delete => :cascade, :on_update => :cascade
    String :dia_semana
    Time :hora
    DateTime    :hora_solicitud
    primary_key [:id_profesor, :id_estudiante, :dia_semana, :hora]
    foreign_key [:dia_semana, :hora, :id_profesor], :tutoria, :on_delete => :cascade, :on_update => :cascade
  end




end