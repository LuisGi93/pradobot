def crear_tablas db
  db.create_table! :usuario do
    primary_key :email, :type => 'varchar(100)'
    String     :tipo_usuario
  end

  db.create_table! :usuario_telegram do
    foreign_key :email, :usuario, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    String      :nombre_usuario
    Integer     :id_telegram
  end

  db.create_table! :usuario_moodle do
    foreign_key :email, :usuario, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    String      :token
    Integer     :id_moodle
    String      :nombre
  end

  db.create_table! :profesor do
    foreign_key :email, :usuario_moodle, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade, :primary_key => true
    Integer     :n_despacho
  end


  db.create_table! :tutoria do
    foreign_key :email, :profesor, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade
    String     :dia_semana_hora
    primary_key [:email, :dia_semana_hora]
  end

  db.create_table! :peticion_tutoria do
    foreign_key :email_profesor, :profesor, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade
    foreign_key :email_alumno, :usuario_moodle, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade
    String      :dia_semana_hora
    DateTime    :hora_solicitud
    primary_key [:email_profesor, :email_alumno, :dia_semana_hora]
  end

  db.create_table! :curso do
    primary_key :id_moodle, :type => 'integer'
    String      :nombre_curso
  end

  db.create_table! :tiene_chat do
    primary_key :id_chat_telegram, :type => 'integer'
    foreign_key :id_moodle_curso, :curso, :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    String      :nombre_curso
  end

  db.create_table! :dudas do
    foreign_key :email, :usuario_moodle, :type => 'varchar(100)', :on_delete => :cascade, :on_update => :cascade
    foreign_key :id_moodle_curso, :curso, :type => 'integer', :on_delete => :cascade, :on_update => :cascade
    String      :contenido
    primary_key [:email, :contenido, :id_moodle_curso]
  end

end