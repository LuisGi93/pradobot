require_relative '../accion'
require 'active_support/inflector'
class AccionAsociarChat< Accion

  @nombre='Asociar chat curso'
  def initialize
    @fase='inicio'
    @id_telegram=nil
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso['nombre_curso']}*", parse_mode: 'Markdown')
    @fase='peticion_nombre_chat'
  end


  def reiniciar
    @fase='inicio'
  end

  def asociar_chat_curso nombre_chat_telegram, id_moodle_curso
    chat=@@db[:chat_telegram].where(:nombre_chat => nombre_chat_telegram)

     if chat.empty?
       @@db[:chat_telegram].insert(:nombre_chat => nombre_chat_telegram.titleize)
       @@db[:chat_curso].insert(:nombre_chat_telegram => nombre_chat_telegram.titleize, :id_moodle_curso => id_moodle_curso)
     else
       puts @@db
       @@db[:chat_curso].where(:id_moodle_curso =>id_moodle_curso ).update(:nombre_chat_telegram => nombre_chat_telegram.titleize)
     end
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

    case @fase
      when 'inicio'
          @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso['nombre_curso']}*", parse_mode: 'Markdown')
          @fase='peticion_nombre_chat'
      when 'peticion_nombre_chat'
        asociar_chat_curso(datos_mensaje, @curso['id_moodle'].to_i)
        texto="Curso *#{@curso['nombre_curso']}*  asociado al chat *#{datos_mensaje}*"
        @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
        reiniciar
    end

  end

  public_class_method :new

end