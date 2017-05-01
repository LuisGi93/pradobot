require_relative '../accion'
require_relative '../../usuarios/curso'
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
    @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso[0].nombre}*", parse_mode: 'Markdown')
    @fase='peticion_nombre_chat'
  end


  def reiniciar
    @fase='inicio'
  end

  def asociar_chat_curso nombre_chat_telegram
    @curso[0].asociar_chat nombre_chat_telegram
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

    case @fase
      when 'inicio'
          @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso[0].nombre}*", parse_mode: 'Markdown')
          @fase='peticion_nombre_chat'
      when 'peticion_nombre_chat'
        @curso[0].asociar_chat datos_mensaje
        texto="Curso *#{@curso[0].nombre}*  asociado al chat *#{datos_mensaje}*"
        @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
        reiniciar
    end

  end

  public_class_method :new

end