require_relative '../accion'
require_relative '../../contenedores_datos/curso'
require_relative '../../contenedores_datos/estudiante'
require_relative '../../../lib/contenedores_datos/peticion'

class SolicitarTutoria < Accion

  @nombre='Realizar/Borrar petición tutoría'
  def initialize
    @fase='inicio'
    @tutorias=Array.new
    @profesor_curso
    @ultimo_mensaje
  end

  def obtener_tutorias_alumno
    profesor_curso=@curso.obtener_profesor_curso
    tutorias=profesor_curso.obtener_tutorias

    return tutorias
  end


  def crear_menu(acciones)
    fila_botones=Array.new
    array_botones=Array.new
    acciones.each{|accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{accion}")
      if array_botones.size == 3
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }
    fila_botones << array_botones
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    return markup
  end

  def crear_menu_indice (acciones, prefijo, tipo)
    fila_botones=Array.new
    array_botones=Array.new
    acciones.each{|accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{prefijo} #{accion}")
      if array_botones.size == 4
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }

    if(tipo =="final")
      fila_botones << array_botones
    else
      fila_botones << array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Volver", callback_data: "#\#$$Volver")
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    return markup
  end

  def mostrar_tutorias opcion
    texto="Seleccione la tutoria desea de #{@profesor_curso.nombre_usuario} son:\n"
    @tutorias.each_with_index { |tutoria, index|
      texto+= "\t *#{index}*) \t Fecha tutoria: *#{tutoria.fecha}*, alumnos en cola: *#{tutoria.numero_peticiones}*\n"
    }
    array_tutorias=[*0..@tutorias.size-1]
    menu=crear_menu_indice(array_tutorias, "Tutoria","final")
    if opcion == "editar_mensaje"
      @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
    else
      @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: texto,reply_markup: menu, parse_mode: "Markdown"  )
    end
  end

  def ejecutar

    @profesor_curso=@curso.obtener_profesor_curso
    tutorias=@profesor_curso.obtener_tutorias
    if tutorias.empty?
      @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: "El profesor *#{@profesor_curso.nombre_usuario}* a cargo de *#{@curso.nombre}* no tiene tutorias", parse_mode: "Markdown" )
    else
      @tutorias=tutorias
      text="Seleccione la tutoria desea de #{@profesor_curso.nombre_usuario} son:\n"
      tutorias.each_with_index { |tutoria, index|
        text+= "\t *#{index}*) \t Fecha tutoria: *#{tutoria.fecha}*, alumnos en cola: *#{tutoria.numero_peticiones}*\n"
      }
      array_tutorias=[*0..tutorias.size-1]
      menu=crear_menu_indice(array_tutorias, "Tutoria","final")
      @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: text,reply_markup: menu, parse_mode: "Markdown"  )
    end

  end

  def crear_menu(acciones)
    fila_botones=Array.new
    array_botones=Array.new
    acciones.each{|accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{accion}")
      if array_botones.size == 3
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }
    fila_botones << array_botones
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    return markup
  end

  def reiniciar
    @tutorias.clear
    @profesor_curso=nil
  end

  def solicitar_tutoria tutoria
      peticion=Peticion.new(tutoria, Estudiante.new(@ultimo_mensaje.id_telegram))
      solicitud_aceptada=@profesor_curso.solicitar_tutoria(peticion)
    return solicitud_aceptada
  end





  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje
    datos_mensaje=@ultimo_mensaje.obtener_datos_mensaje
    case datos_mensaje
      when /\#\#\$\$Tutoria/
        datos_mensaje.slice! "#\#$$Tutoria"
        #fecha_tutoria=datos_mensaje[/[^_]*/].to_i
        acciones=["Volver"]
        menu=crear_menu(acciones)
        if solicitar_tutoria @tutorias.at(datos_mensaje.to_i)
          @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Recibido")
          @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, reply_markup: menu,text:   "Solicitud para la tutoria #{@tutorias.at(datos_mensaje.to_i).fecha} registrada.", parse_mode: "Markdown"  )
        else
          @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "No disponible")
          @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, reply_markup: menu, text:   "La tutoria elegida no está disponible, compruebe si ya ha solicitado para dicha sesión sino vuelva a intentarlo", parse_mode: "Markdown")
        end
      when /\#\#\$\$Volver/
        mostrar_tutorias("editar_mensaje")
        @fase=""
      else
        @profesor_curso=@curso.obtener_profesor_curso
        @tutorias=@profesor_curso.obtener_tutorias
        mostrar_tutorias("nuevo_mensaje")
    end
  end



  public_class_method :new

end