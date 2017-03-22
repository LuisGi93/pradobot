require_relative 'accion_profesor'

class AccionVerCursos< AccionProfesor

  @nombre='Ver cursos'
  def initialize accion_padre
    @estado='inicio'
    @id_telegram=nil
    @accion_padre=accion_padre
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
  end

  def cambiar_curso(curso)
    @curso=curso
  end

  def mandar_informacion_cursos cursos
    kb = Array.new
    if cursos
      cursos.each{|curso|
        nombre_curso=curso[:nombre_curso]
        id_curso="curso_"+curso[:nombre_curso]
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: nombre_curso, callback_data: "curso_#{nombre_curso}")
        #kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: nombre_curso, callback_data: id_curso)

      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      @@bot.api.send_message( chat_id: @id_telegram, text: 'Cursos disponibles:', reply_markup: markup)
    end
  end

  def reiniciar
  end
  def ejecutar(id_telegram)
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    cursos=obtener_cursos_profesor
    if cursos && cursos.size > 0
      mandar_informacion_cursos(cursos)
    else
      @@bot.api.send_message( chat_id: @id_telegram, text: 'No hay cursos que mostrar.')
    end
  end


  def mostrar_informacion_curso nombre_curso
    curso=@@db[:cursos].where(:nombre_curso => nombre_curso).to_a[0]
    if curso[:nombre_chat_telegram]
      texto="*Nombre:* #{curso[:nombre_curso]}
*Id_curso:* #{curso[:id_curso_moodle]}
*Chat telegram*:#{curso[:nombre_chat_telegram]}"
    else
      texto="*Nombre:* #{curso[:nombre_curso]}
*Id_curso:* #{curso[:id_curso_moodle]}"
    end

    @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    siguiente_accion=self

    if datos_mensaje  =~ /curso_.+/

      datos_mensaje.slice! "curso_"
      mostrar_informacion_curso(datos_mensaje)
    else
      ejecutar(@id_telegram)
    end


    return siguiente_accion
  end

  def obtener_cursos_profesor
    cursos_profesor= @@db[:cursos].where(:id_telegram_profesor_responsable => @id_telegram).to_a
  end


end