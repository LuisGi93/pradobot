require_relative 'accion_profesor'
class AccionElegirCurso < AccionProfesor

  @nombre='Seleccionar curso'
  def initialize padre
    @fase='inicio'
    @datos=Hash.new
    @id_telegram=nil
    @padre=padre
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
  end

  def elegir_curso cursos
    kb = Array.new
    if cursos
      cursos.each{|curso|
        nombre_curso=curso[:nombre_curso]
        id_curso="Cambiar a curso "+curso[:nombre_curso]
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: nombre_curso, callback_data: "curso_#{nombre_curso}")
      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      @@bot.api.send_message( chat_id: @id_telegram, text: 'Elija curso:', reply_markup: markup)
    end
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    cursos=obtener_cursos_profesor
    if cursos
      elegir_curso(cursos)
    else
      @@bot.api.send_message( chat_id: @id_telegram, text: 'No tiene ningún curso luego no puede usar el bot.')
    end
    return self
  end


  def reiniciar
    @fase='inicio'
    @datos.clear
  end



  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=self
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

        if datos_mensaje  =~ /curso_.+/

          datos_mensaje.slice! "curso_"
          @fase='peticion_nombre_chat'
          @padre.cambiar_curso(datos_mensaje)
          siguiente_accion=@padre
          @padre.ejecutar(id_telegram)
        else
          ejecutar(@id_telegram)
        end

    return siguiente_accion
  end

  def obtener_cursos_profesor
    cursos_profesor= @@db[:cursos].where(:id_telegram_profesor_responsable => @id_telegram).to_a
  end


end