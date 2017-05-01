require_relative '../accion'
require_relative '../../usuarios/curso'
require_relative '../../usuarios/estudiante'
require_relative '../../usuarios/duda'
class CrearDuda < Accion

  @nombre='Crear una nueva duda'
  def initialize
    @fase='inicio'
    @duda
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
        text="Escriba a continuación la duda que desea crear relacionada con *#{curso[0].nombre}*\n"
        @@bot.api.send_message( chat_id: @id_telegram, text: text, parse_mode: "Markdown"  )
    else
      #todo
    end

    @fase="escribiendo_duda"
  end


  def reiniciar
    @duda=nil
    @fase="inicio"
    @id_telegram=nil
  end

  def confirmar_denegar_duda
    if @curso.size < 2
      fila_botones=Array.new
      array_botones=Array.new
        text= "¿Crear nueva duda para el curso: *#{curso[0].nombre}*\n Duda: *#{@duda}* "
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Crear", callback_data: "crear_duda_")
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Descartar", callback_data: "descartar_duda_")

      fila_botones << array_botones

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
      @@bot.api.send_message( chat_id: @id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )

    else
      #todo
    end
  end



  def crear_descartar_duda datos_mensaje, id_mensaje
    if @curso.size < 2

      if datos_mensaje =~ /crear_duda_/
        estudiante= Estudiante.new(@id_telegram)
        duda= Duda.new(@duda)
        @curso[0].nueva_duda(duda, estudiante)

        @@bot.api.answer_callback_query(callback_query_id: id_mensaje, text: "Creada")
        @@bot.api.send_message( chat_id: @id_telegram, text:   "Se ha creado una nueva duda con el contenido: *#{@duda}*", parse_mode: "Markdown")
      end
    else
      #todo
    end

  end


  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      @id_telegram=id_telegram
    end

    if @fase=="escribiendo_duda"
      @duda=datos_mensaje
      confirmar_denegar_duda
      @fase="solicitar_confirmacion"
    elsif datos_mensaje =~ /(crear_duda_|descartar_duda_)/
      crear_descartar_duda datos_mensaje, mensaje.obtener_identificador_mensaje
      reiniciar
    else
      ejecutar(id_telegram)
    end
  end



  public_class_method :new

end