require_relative 'listar_dudas'
#
# Clase encargada de mostrar dudas sin resolver de un curso. 
class ListarDudasPendientes < ListarDudas
  @nombre = 'Sin resolver'

  #
  # Muestra al usuario un mensaje solicitando que introduzca el texto de la duda.
  #   # * *Args*    :
  #   - +opcion+ -> determina si se manda un nuevo mensaje al chat del usuario o se edita el último mensaje enviado. 
  #
  def mostrar_dudas(opcion)
    @dudas = @curso.obtener_dudas_sin_resolver
    if @dudas.empty?
      texto = "El curso #{@curso.nombre} no hay ninguna duda pendiente de respuesta."
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto)
    else
      texto = "Dudas sin solución para #{@curso.nombre} son:\n"
      texto += crear_indice_respuestas_dudas(@dudas)
      indices_dudas = [*0..@dudas.size - 1]
      menu = MenuInlineTelegram.crear_menu_indice(indices_dudas, 'Duda', 'final')
      texto += 'Elija una duda:'
      if opcion == 'editar_mensaje'
        @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, reply_markup: menu, parse_mode: 'Markdown')
      else
        @id_ultimo_mensaje_respuesta = @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto, reply_markup: menu, parse_mode: 'Markdown')['result']['message_id']

      end
    end
  end

  #  
  #  *Args*    :
  #   - +opcion+ -> determina si se manda un nuevo mensaje al chat del usuario o se edita el último mensaje enviado. 
  #
  def generar_respuesta_mensaje
    datos_mensaje = @ultimo_mensaje.datos_mensaje

    if @ultimo_mensaje.tipo == 'callbackquery'
      if datos_mensaje =~ /\#\#\$\$Volver/
        mostrar_menu_anterior
      else
        respuesta_segun_accion_pulsada datos_mensaje
      end
    else
      if @fase == 'responder_duda'
        nueva_respuesta_duda(datos_mensaje)
      else
        mostrar_dudas('nuevo_mensaje')
      end
    end
  end

  def reiniciar
    if @id_ultimo_mensaje_respuesta
      @@bot.api.delete_message(chat_id: @ultimo_mensaje.id_chat, message_id: @id_ultimo_mensaje_respuesta)
    end
  end

  public_class_method :new
  private :generar_respuesta_mensaje
  protected :mostrar_dudas
end
