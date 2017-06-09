class ListarDudas < Accion

  @nombre="Listar dudas pendientes."
  def initialize
    @dudas=Array.new
    @indice_duda_seleccionada=nil
    @fase=nil
    @ultimo_mensaje=nil
  end


  def crear_indice_respuestas_dudas  respuestas_dudas
    texto=""
    respuestas_dudas.each_with_index { |respuesta_duda, indice|
      texto+="    (*#{indice}*) (#{respuesta_duda.usuario.nombre_usuario}): \t #{respuesta_duda.contenido}\n"
    }
    return texto
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


  def mostrar_acciones(datos_mensaje)
    solucion_duda=@dudas[@indice_duda_seleccionada].solucion
    creador_o_profesor=@curso.obtener_profesor_curso.id_telegram == @ultimo_mensaje.id_telegram || @dudas[@indice_duda_seleccionada].usuario.id_telegram==@ultimo_mensaje.id_telegram
    if creador_o_profesor && solucion_duda
      acciones=["Solución duda", "Todas respuestas", "Borrar duda", "Volver"]
    elsif  creador_o_profesor
      acciones=["Responder duda", "Borrar duda", "Ver respuestas", "Volver"]
    elsif solucion_duda
      acciones=["Solución duda", "Todas respuestas", "Volver"]
    else
      acciones=["Responder duda", "Ver respuestas", "Volver"]
    end
    menu=crear_menu(acciones)
    texto="Duda elegida *#{@dudas.at(@indice_duda_seleccionada).contenido}*. Elija que desea hacer:"
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
  end


  def crear_indice_respuestas  respuestas
    texto=""
    respuestas.each_with_index { |respuesta, indice|
      texto+="    (*#{indice}*) (#{respuesta.usuario.nombre_usuario}): \t #{respuesta.contenido}\n"
    }
    return texto
  end



  def mostrar_respuestas
    texto="Duda elegida *#{@dudas.at(@indice_duda_seleccionada).contenido}*. Ha tenido las siguientes respuestas:\n"
    solucion_duda=@dudas[@indice_duda_seleccionada].solucion
    creador_o_profesor=@curso.obtener_profesor_curso.id_telegram == @ultimo_mensaje.id_telegram || @dudas[@indice_duda_seleccionada].usuario.id_telegram ==@ultimo_mensaje.id_telegram
    puts creador_o_profesor
    if creador_o_profesor && solucion_duda.nil?
      acciones=["Elegir solución.","Volver"]
      puts solucion_duda.to_s
      puts solucion_duda.nil?
    else
      acciones=["Volver"]
    end
    texto="Duda elegida *#{@dudas.at(@indice_duda_seleccionada).contenido}*. Ha tenido las siguientes respuestas:\n"
    @respuestas=@dudas.at(@indice_duda_seleccionada).respuestas
    texto+=crear_indice_respuestas(@respuestas)
    menu=crear_menu(acciones)
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
  end

  def elegir_respuesta
    texto="Elija respuesta que resuelve *#{@dudas.at(@indice_duda_seleccionada).contenido}*.\n"
    @respuestas=@dudas.at(@indice_duda_seleccionada).respuestas
    texto+=crear_indice_respuestas(@respuestas)
    indices_respuestas=[*0..@respuestas.size-1]
    menu=crear_menu_indice(indices_respuestas, "Respuesta", "no_final")
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
  end

  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje
    #Responder duda, borrar duda, marca respuesta duda, ver respuestas.
    #Y en el menu crear nueva duda, listar dudas pendientes, listar mis dudas.
    generar_respuesta_mensaje(mensaje)

  end

  def reiniciar
    @ultimo_mensaje=nil
    @dudas=Array.new
    @respuestas=Array.new
    @indice_duda_seleccionada=nil
    @fase=nil
  end


  def respuesta_segun_accion_pulsada datos_mensaje
    case datos_mensaje
      when /\#\#\$\$duda_.+/
        datos_mensaje.slice! "#\#$$duda_"
        @indice_duda_seleccionada=datos_mensaje.to_i
        mostrar_acciones(datos_mensaje)
        @fase="mostrar_dudas_pendientes"
      when  /\#\#\$\$Responder duda/
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Recibido!")
        # @@bot.api.delete_message(chat_id: @ultimo_mensaje.id_telegram, message_id: @ultimo_mensaje.id_mensaje2["result"]["message_id"])
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text:  "Introduzca respuesta a *#{@dudas.at(datos_mensaje.to_i).contenido}*:", parse_mode: "Markdown"  )
        @fase="responder_duda"
      when /\#\#\$\$Borrar duda/
        @curso.eliminar_duda(@dudas.at(@indice_duda_seleccionada))
        acciones=["Volver"]
        menu=crear_menu(acciones)
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, reply_markup: menu, text: "Borrada!")
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: "Duda eliminada correctamente.", reply_markup: menu,  parse_mode: "Markdown"  )
        reiniciar
        @fase="mostrar_dudas_pendientes"
        #@@bot.api.delete_message(chat_id: @ultimo_mensaje.id_telegram, message_id: @ultimo_mensaje.id_mensaje)
      when  /\#\#\$\$Elegir solución/
        datos_mensaje.slice! "#\#$$Seleccionar respuesta duda"
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Por hacer")
        elegir_respuesta
        @fase="resolver_duda_elegir_respuesta"
      when  /\#\#\$\$Ver respuestas/
        datos_mensaje.slice! "#\#$$Ver respuestas"
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Obteniendo respuestas...")
        @fase="opciones_sobre_duda"
        mostrar_respuestas
      when  /\#\#\$\$Respuesta/
        datos_mensaje.slice! "#\#$$Respuesta"
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Respuesta elegida")
        @fase="opciones_sobre_duda"
        resolver_duda(datos_mensaje.to_i)
    end

  end



  def generar_respuesta_mensaje(mensaje)

    datos_mensaje=mensaje.obtener_datos_mensaje

    puts datos_mensaje
    if mensaje.tipo== "callbackquery"
      if datos_mensaje =~ /\#\#\$\$Volver/
        mostrar_menu_anterior
      else
        respuesta_segun_accion_pulsada datos_mensaje
      end
    else
      if @fase == "responder_duda"
        nueva_respuesta_duda(datos_mensaje)
      else
        mostrar_dudas("nuevo_mensaje")
      end
    end

  end

  def nueva_respuesta_duda contenido_respuesta
    usuario=Usuario.new(@ultimo_mensaje.id_telegram)
    respuesta=Respuesta.new(contenido_respuesta, usuario, @dudas.at(@indice_duda_seleccionada))
    @dudas.at(@indice_duda_seleccionada).nueva_respuesta(respuesta)
    acciones=["Volver"]
    menu=crear_menu(acciones)
    @fase="opciones_sobre_duda"
    @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text:  "Respuesta *#{contenido_respuesta}* guardada correctamente.",reply_markup: menu,  parse_mode: "Markdown"  )
  end

  def resolver_duda indice_respuesta
    puts "resolvermos la jodida "
    @dudas.at(@indice_duda_seleccionada).insertar_solucion(@respuestas.at(indice_respuesta))
    @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text:  "Duda #{@dudas.at(@indice_duda_seleccionada).contenido} resuelta por *#{@respuestas.at(indice_respuesta).contenido}*", parse_mode: "Markdown"  )
    @fase=nil
  end


  def mostrar_menu_anterior

    puts @fase
    case @fase
      when "mostrar_dudas_pendientes"
        mostrar_dudas("editar_mensaje")
        @fase=""
      when "opciones_sobre_duda"
        mostrar_acciones(@indice_duda_seleccionada)
#        mostrar_dudas_pendientes("editar_mensaje")
        @fase="mostrar_dudas_pendientes"
      when "mostrando_respuestas"
        mostrar_dudas_pendientes("editar_mensaje")
        @fase="opciones_sobre_duda"
      when "borrar_duda"
        mostrar_acciones(@indice_duda_seleccionada)
        @fase=""
      when "resolver_duda"
        mostrar_acciones(@indice_duda_seleccionada)
        @fase="opciones_sobre_duda"
      when "solucion_duda"
        mostrar_acciones(@indice_duda_seleccionada)
        @fase="opciones_sobre_duda"
      when "resolver_duda_elegir_respuesta"
        @fase="mostrando_respuestas"
        mostrar_respuestas
    end
  end

  def mostrar_solucion_duda
    solucion_duda=@dudas.at(@indice_duda_seleccionada).solucion
    puts solucion_duda.to_s
    texto="Duda: *#{@dudas.at(@indice_duda_seleccionada).contenido}* \n Solución: *#{solucion_duda.contenido}*."
    acciones=[ "Volver"]
    menu=crear_menu(acciones)
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
  end

  public_class_method :new

end

require_relative 'accion'
require_relative '../contenedores_datos/curso'
require_relative '../contenedores_datos/usuario'
require_relative '../contenedores_datos/duda'
require_relative '../contenedores_datos/respuesta'