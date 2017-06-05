require_relative 'listar_dudas'
class ListarDudasPendientes < ListarDudas

  @nombre= 'Sin resolver'

  def mostrar_dudas opcion

    @dudas=@curso.obtener_dudas_sin_resolver
    if @dudas.empty?
      texto="El curso #{@curso.nombre} no hay ninguna duda pendiente de respuesta."
      @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: texto)
    else
      texto="Dudas sin solución para #{@curso.nombre} son:\n"
      texto+=crear_indice_respuestas_dudas(@dudas)
      indices_dudas=[*0..@dudas.size-1]
      menu=crear_menu_indice(indices_dudas, "duda_", "final")
      texto+="Elija una duda:"
      if opcion == "editar_mensaje"
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )
      else
        @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: texto,reply_markup: menu, parse_mode: "Markdown"  )
      end
    end

  end

  def generar_respuesta_mensaje(mensaje)

    datos_mensaje=mensaje.obtener_datos_mensaje

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


  public_class_method :new

end
