require_relative 'accion'
require_relative '../../lib/contenedores_datos/usuario'

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
    fila_botones=Array.new
    array_botones=Array.new
    contador=0

    if cursos
      cursos.each{|curso|

        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: curso.nombre, callback_data: "curso_#{curso.id_curso}##")
        if array_botones.size == 2
          fila_botones << array_botones.dup
          array_botones.clear
        end
        contador+=1

      }

      fila_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Todos cursos", callback_data: "curso_-99")

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)

      @@bot.api.send_message( chat_id: @id_telegram, text: 'Elija curso:', reply_markup: markup)
    end
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

    cursos=obtener_cursos_usuario(id_telegram)
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
      id_curso = datos_mensaje[/-?[0-9]{1,2}/]
      id_curso=id_curso.to_i
      @padre.iniciar_cambio_curso(id_telegram,id_curso)
      siguiente_accion=@padre
      @padre.ejecutar(id_telegram)
    else
      ejecutar(@id_telegram)
    end

    return siguiente_accion
  end

  def obtener_cursos_usuario id_telegram
    usuario=Usuario.new(id_telegram)
    return usuario.obtener_cursos_usuario
  end

  public_class_method :new

end