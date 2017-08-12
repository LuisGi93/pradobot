class ListarDudasResueltas < ListarDudas

  @nombre= 'Resueltas'

  def mostrar_dudas opcion

    @dudas=@curso.obtener_dudas_resueltas
    if @dudas.empty?
      texto="El curso #{@curso.nombre} no hay ninguna duda resuelta."
      @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto)
    else
      texto="Dudas resueltas para #{@curso.nombre} son:\n"
      texto+=crear_indice_respuestas_dudas(@dudas)
      indices_dudas=[*0..@dudas.size-1]
      menu=MenuInlineTelegram.crear_menu_indice(indices_dudas, "Duda", "final")
      texto+="Elija una duda:"
      if opcion == "editar_mensaje"
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
      else
        @id_ultimo_mensaje_respuesta=@@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto,reply_markup: menu, parse_mode: "Markdown")["result"]["message_id"]
        puts @mensaje
      end
    end

  end



  def mostrar_acciones(datos_mensaje)

    solucion_duda=@dudas[@indice_duda_seleccionada].solucion
    creador_o_profesor=@curso.obtener_profesor_curso.id_telegram == @ultimo_mensaje.usuario.id_telegram || @dudas[@indice_duda_seleccionada].usuario.id_telegram
    if creador_o_profesor && solucion_duda
      @acciones=[ "Solución duda", "Todas respuestas", "Borrar duda", "Volver"]
    else
      @acciones=["Todas respuestas", "Volver"]
    end
    menu=MenuInlineTelegram.crear(@acciones)
    puts "@l indice de la duda es #{@indice_duda_seleccionada}"
    texto="Duda elegida *#{@dudas.at(@indice_duda_seleccionada).contenido}*. Elija que desea hacer:"
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
  end

def reiniciar

    if @id_ultimo_mensaje_respuesta
     @@bot.api.delete_message(chat_id: @ultimo_mensaje.id_chat, message_id: @id_ultimo_mensaje_respuesta)
    end
end


  def respuesta_segun_accion_pulsada datos_mensaje
    puts datos_mensaje

    case datos_mensaje
      when /\#\#\$\$duda_.+/
        datos_mensaje.slice! "#\#$$duda_"
        @indice_duda_seleccionada=datos_mensaje.to_i
        mostrar_acciones(datos_mensaje)
        @fase="mostrar_dudas_pendientes"
      when "borrar_duda"
        mostrar_acciones(@indice_duda_seleccionada)
        @fase="mostrar_dudas_pendientes"
      when /\#\#\$\$Solución duda/
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Buscando solución...")
        mostrar_solucion_duda
        @fase="opciones_sobre_duda"
      when  /\#\#\$\$Todas respuestas/
        datos_mensaje.slice! "#\#$$Ver respuestas"
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Obteniendo respuestas...")
        @fase="opciones_sobre_duda"
        mostrar_respuestas
      else
        super
    end

  end



  public_class_method :new

end
require_relative 'listar_dudas'
