require_relative '../accion'
require_relative '../../usuarios/curso'
require_relative '../../usuarios/estudiante'
require_relative '../../../lib/usuarios/peticion'

class SolicitarTutoria < Accion

  @nombre='Realizar/Borrar petición tutoría'
  def initialize
    @fase='inicio'
    @tutorias=Array.new
    @profesores=Array.new
    @id_telegram=nil
  end

  def obtener_tutorias_alumno
    if @curso.size < 2
      profesor_curso=curso[0].obtener_profesor_curso
      tutorias=profesor_curso.obtener_tutorias
    else
      #todo
    end
    return tutorias
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    #tutorias=obtener_tutorias_alumno

    if @curso.size < 2
      profesor_curso=@curso[0].obtener_profesor_curso
      tutorias=profesor_curso.obtener_tutorias
      puts tutorias.to_s
      if tutorias.empty?
        @@bot.api.send_message( chat_id: id_telegram, text: "El profesor *#{profesor_curso.nombre_usuario}* a cargo de *#{curso[0].nombre}* no tiene tutorias", parse_mode: "Markdown" )
      else
        @tutorias=tutorias
        @profesores << profesor_curso
        text="Seleccione la tutoria desea de #{profesor_curso.nombre_usuario} son:\n"
        fila_botones=Array.new
        array_botones=Array.new
        tutorias.each_with_index { |tutoria, index|
          puts tutoria.fecha
          puts tutoria.numero_peticiones
          text+= "\t *#{index}*) \t Fecha tutoria: *#{tutoria.fecha}*, alumnos en cola: *#{tutoria.numero_peticiones}*\n"
          array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: index, callback_data: "tutoria_#{tutoria.fecha}")
          if array_botones.size == 3
            fila_botones << array_botones.dup
            array_botones.clear
            puts array_botones.to_s
          end
        }
        fila_botones << array_botones

        #markup=Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [[kb[0], kb[1]], [kb[2]]])

        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
        @@bot.api.send_message( chat_id: id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )
      end
    else
      #todo
    end


  end


  def reiniciar
    @tutorias.clear
    @profesores.clear
    @id_telegram=nil
  end

  def solicitar_tutoria fecha_tutoria
    if @curso.size < 2
      tutoria=Tutoria.new(@profesores[0], fecha_tutoria)
      peticion=Peticion.new(tutoria, Estudiante.new(@id_telegram))
      solicitud_aceptada=@profesores[0].solicitar_tutoria (peticion)
    else
      #todo
    end


    return solicitud_aceptada
  end





  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    if datos_mensaje =~ /tutoria_/

      datos_mensaje.slice! "tutoria_"
      fecha_tutoria=datos_mensaje[/[^_]*/]
      if solicitar_tutoria fecha_tutoria
        @@bot.api.answer_callback_query(callback_query_id: mensaje.obtener_identificador_mensaje, text: "Recibido")
        @@bot.api.send_message( chat_id: id_telegram, text:   "Solicitud para la tutoria #{fecha_tutoria} registrada.", parse_mode: "Markdown"  )
      else
        @@bot.api.answer_callback_query(callback_query_id: mensaje.obtener_identificador_mensaje, text: "No disponible")
        @@bot.api.send_message( chat_id: id_telegram, text:   "La tutoria elegida no está disponible, compruebe si ya ha solicitado para dicha sesión sino vuelva a intentarlo", parse_mode: "Markdown")
      end
    else
      ejecutar(id_telegram)
    end
  end



  public_class_method :new

end