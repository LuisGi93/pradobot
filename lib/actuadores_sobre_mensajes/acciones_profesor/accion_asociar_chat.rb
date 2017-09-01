require_relative '../accion'
require_relative '../../contenedores_datos/curso'
class AccionAsociarChat < Accion
  @nombre = 'Asociar chat curso'
  def initialize
    @fase = 'inicio'
    @ultimo_mensaje = nil
    end

  def reiniciar
    @fase = 'inicio'
  end

  def recibir_mensaje(mensaje)
    case @fase
    when 'inicio'
      @@bot.api.send_message(chat_id: mensaje.usuario.id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso.nombre}*", parse_mode: 'Markdown')
      @fase = 'peticion_nombre_chat'
    when 'peticion_nombre_chat'
      @curso.asociar_chat mensaje.datos_mensaje
      texto = "Curso *#{@curso.nombre}*  asociado al chat *#{mensaje.datos_mensaje}*"
      @@bot.api.send_message(chat_id: mensaje.usuario.id_telegram, text: texto, parse_mode: 'Markdown')
      reiniciar
    end
  end

  public_class_method :new
end
