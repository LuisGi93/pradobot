require_relative 'accion'
require_relative '../contenedores_datos/curso'
require_relative '../contenedores_datos/estudiante'
require_relative '../contenedores_datos/duda'
class CrearDuda < Accion

  @nombre='Nueva duda'
  def initialize
    @fase='inicio'
    @duda
    @ultimo_mensaje=nil
  end


  def solicitar_escribir_duda
    text="Escriba a continuación la duda que desea crear relacionada con *#{@curso.nombre}*:\n"
    @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: text, parse_mode: "Markdown"  )
    @fase="escribiendo_duda"
  end


  def reiniciar
    @duda=nil
    @fase="inicio"
    @ultimo_mensaje=nil
  end

  def confirmar_denegar_duda
      fila_botones=Array.new
      array_botones=Array.new
        text= "¿Crear nueva duda para el curso: *#{@curso.nombre}*\n Duda: *#{@duda}* "
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Crear", callback_data: "crear_duda_")
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Descartar", callback_data: "descartar_duda_")

      fila_botones << array_botones

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
      @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )

  end



  def crear_descartar_duda
      if @ultimo_mensaje.datos_mensaje =~ /crear_duda_/
        estudiante= Estudiante.new(@ultimo_mensaje.usuario.id_telegram)
        duda= Duda.new(@duda, estudiante)
        @curso.nueva_duda(duda)
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Creada")
        texto='Elija una opción del menú:'
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: "Se ha creado una nueva duda con el contenido: *#{@duda}*", parse_mode: "Markdown" )
      else
        @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Descartada")
       # @@bot.api.delete_message( chat_id: @id_chat, message_id: @id_mensaje)
        texto='Elija una opción del menú:'
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto, parse_mode: "Markdown" )
        reiniciar
        #@@bot.api.send_message( chat_id: @id_telegram, text:   "Se ha creado una nueva duda con el contenido: *#{@duda}*", parse_mode: "Markdown")
      end


  end


  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje

    if @fase=="escribiendo_duda"
      @duda=@ultimo_mensaje.datos_mensaje
      confirmar_denegar_duda
      @fase="solicitar_confirmacion"
    elsif @ultimo_mensaje.datos_mensaje =~ /(crear_duda_|descartar_duda_)/
      crear_descartar_duda
      reiniciar
    else
      solicitar_escribir_duda
    end
  end



  public_class_method :new

end
