require_relative 'listar_dudas'
class ListarMisDudas < ListarDudas
  @nombre = 'Mis dudas'

  def reiniciar
    if @id_ultimo_mensaje_respuesta
      @@bot.api.delete_message(chat_id: @ultimo_mensaje.id_chat, message_id: @id_ultimo_mensaje_respuesta)
    end
  end

  #
  #  Envía al usuario un mensaje en el que se muestran las dudas sin resolver del curos
     # * *Args*    :
  #   - +opcion+ -> determina si se manda un nuevo mensaje al chat del usuario o se edita el último mensaje enviado.
  #
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
      @id_ultimo_mensaje_respuesta=@@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto)['result']['message_id']
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

  #  Elije que hace en función del botón pulsado por el usuario
  #    *Args*    :
  #   - +datos_mensaje+ -> datos del último mensaje recibido
  #
  #
  def respuesta_segun_accion_pulsada(datos_mensaje)

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
