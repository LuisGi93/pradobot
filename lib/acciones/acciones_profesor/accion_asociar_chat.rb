require_relative 'accion_profesor'
require 'active_support/inflector'
class AccionAsociarChat< AccionProfesor

  @nombre='Asociar chat curso'
  def initialize accion_padre
    @fase='inicio'
    @datos=Hash.new
    @id_telegram=nil
    @accion_padre=accion_padre
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{}*", parse_mode: 'Markdown')
    @fase='peticion_nombre_chat'
  end


  def reiniciar
    @fase='inicio'
    @datos.clear
  end

  def asociar_chat_curso chat, curso
     @@db[:cursos].where(:nombre_curso => curso).update(:nombre_chat_telegram => chat.titleize).to_s
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=self
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

    case @fase
      when 'inicio'
          @@bot.api.send_message( chat_id: @id_telegram, text: "Introduzca el nombre del chat al cual quiere asociar *#{@curso}*", parse_mode: 'Markdown')
          @fase='peticion_nombre_chat'
      when 'peticion_nombre_chat'
        asociar_chat_curso(datos_mensaje, @curso)
        texto="Curso *#{@curso}* asociado al chat *#{datos_mensaje}*"
        @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
        reiniciar
    end


    return siguiente_accion
  end

  def obtener_cursos_profesor
    cursos_profesor= @@db[:cursos].where(:id_telegram_profesor => @id_telegram).to_a
  end


end