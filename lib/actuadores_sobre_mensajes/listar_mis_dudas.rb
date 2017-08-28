require_relative 'listar_dudas'
class ListarMisDudas < ListarDudas
  @nombre = 'Mis dudas'

  def reiniciar
    if @id_ultimo_mensaje_respuesta
      @@bot.api.delete_message(chat_id: @ultimo_mensaje.id_chat, message_id: @id_ultimo_mensaje_respuesta)
    end
  end

  def mostrar_dudas(opcion)
    dudas_usuario = UsuarioRegistrado.new(@ultimo_mensaje.usuario.id_telegram).dudas
    dudas_curso = @curso.dudas
    @dudas = []
    dudas_curso.each do |duda_curso|
      dudas_usuario.each do |duda_usuario|
        @dudas << duda_curso if duda_curso == duda_usuario
      end
    end
    if @dudas.empty?
      texto = "No ha creado ninguna duda para el curso #{@curso.nombre}."
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto)
    else
      texto = "Sus dudas creadas para #{@curso.nombre} son:\n"
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

  def respuesta_segun_accion_pulsada(datos_mensaje)
    puts "Datos del mensaje es #{datos_mensaje}"
    case datos_mensaje
    when /\#\#\$\$Solución duda/
      #        @curso.eliminar_duda(@dudas.at(@indice_duda_seleccionada))
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Buscando solución...')
      mostrar_solucion_duda

      # @fase="solucion_duda"
      @fase = 'opciones_sobre_duda'
    when /\#\#\$\$Todas respuestas/
      datos_mensaje.slice! "#\#$$Ver respuestas"
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Obteniendo respuestas...')
      @fase = 'opciones_sobre_duda'
      mostrar_respuestas
    else
      super
    end
  end

  public_class_method :new
  protected :mostrar_dudas
  private :respuesta_segun_accion_pulsada, :mostrar_acciones
end
