require_relative 'listar_dudas'
class ListarMisDudas < ListarDudas

  @nombre= 'Mis dudas'

  def mostrar_dudas opcion


    dudas_usuario=Usuario.new(@ultimo_mensaje.id_telegram).dudas
    dudas_curso=@curso.dudas
    @dudas=Array.new
    dudas_curso.each{|duda_curso|
      dudas_usuario.each{|duda_usuario|

        if(duda_curso==duda_usuario)
          @dudas << duda_curso
        end
      }

    }
    if @dudas.empty?
      texto="No ha creado ninguna duda para el curso #{@curso.nombre}."
      @@bot.api.send_message( chat_id: @ultimo_mensaje.id_telegram, text: texto)
    else
      texto="Sus dudas creadas para #{@curso.nombre} son:\n"
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

  def respuesta_segun_accion_pulsada datos_mensaje

    puts "Datos del mensaje es #{datos_mensaje}"
    case datos_mensaje
      when /\#\#\$\$Solución duda/
#        @curso.eliminar_duda(@dudas.at(@indice_duda_seleccionada))
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Buscando solución...")
        mostrar_solucion_duda

        #@fase="solucion_duda"
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

=begin
  def mostrar_menu_anterior
    case @fase
      when "mostrando_respuestas"
        @dudas.clear
        mostrar_acciones(@indice_duda_seleccionada)
        @fase="opciones_sobre_duda"
      when "solucion_duda"
        mostrar_acciones(@indice_duda_seleccionada)
        @fase="opciones_sobre_duda"
      else
        super
    end
  end

=end


  public_class_method :new

end
