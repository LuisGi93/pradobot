require 'sequel'

#Clase de la que heredan todas aquellas que quieran utilizar la base de datos de la aplicación 
class ConexionBD
  @@db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])

  def verificar_entrada_texto string

    palabras_clave=['id_moodle', 'nombre_curso', 'id_chat', 'nombre_chat', 'chat_curso', 'nombre_chat_telegram',
                   'id_moodle_curso', 'nombre_chat_telegram', 'usuario_telegram', 'nombre_usuario' , 'id_telegram',
                   'usuario_telegram', 'estudiante_curso', 'id_moodle_curso', 'usuarios_moodle', 'token',
                   'id_profesor', 'dia_semana_hora', 'estado', 'hora_solicitud', 'id_usuario_duda', 'contenido_duda',
                   'id_usuario_respuesta', 'contenido_respuesta', 'respuesta_resuelve_duda']
    if palabras_clave.include?(string)
      return false
    else
      return true
    end

  end
end
