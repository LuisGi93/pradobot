require_relative 'accion'
class AccionElegirCurso < Accion

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
      puts "Cursos que llegan#{cursos.to_s}"
      cursos.each{|curso|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: curso['nombre_curso'], callback_data: "curso_#{curso['id_moodle']}_#{curso['nombre_curso']}")
      }
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Todos cursos", callback_data: "curso_-1")

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      @@bot.api.send_message( chat_id: @id_telegram, text: 'Elija curso:', reply_markup: markup)
    end
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    cursos=obtener_cursos_usuario
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

    puts datos_mensaje
        if datos_mensaje  =~ /curso_.+/
          datos_mensaje.slice! "curso_"
          id_moodle = datos_mensaje[/[0-9]{1,2}/]
          datos_mensaje.slice! "#{id_moodle}_"
          @padre.cambiar_curso(datos_mensaje,id_moodle)
          siguiente_accion=@padre
          @padre.ejecutar(id_telegram)
        else
          ejecutar(@id_telegram)
        end

    return siguiente_accion
  end

  def obtener_cursos_usuario
    id_cursos= @@db[:profesor_curso].where(:id_profesor => @id_telegram).select(:id_moodle_curso).to_a
    if id_cursos.empty?
      id_cursos= @@db[:estudiante_curso].where(:id_estudiante => @id_telegram).select(:id_moodle_curso).to_a
    end
    cursos=Array.new
    id_cursos.each{|id|
      curso=@@db[:curso].where(:id_moodle =>id[:id_moodle_curso]).first
      cursos << {"nombre_curso" => curso[:nombre_curso], "id_moodle" => curso[:id_moodle]}
    }
    return cursos
  end

  public_class_method :new

end