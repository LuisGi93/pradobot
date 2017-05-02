require_relative '../accion'
require_relative '../../usuarios/tutoria'
require 'active_support/inflector'
class BorrarTutorias < Accion

  attr_accessor :teclado_menu_padre
  @nombre='Borrar tutoría.'
  def initialize
    @profesor=nil
    @id_telegram=nil
    @teclado_menu_padre=nil
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
  end

  def reiniciar
    @profesor=nil
    @id_telegram=nil
  end
  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    if @curso.size < 2
      @profesor=@curso[0].obtener_profesor_curso
      tutorias=@profesor.obtener_tutorias
      if tutorias.empty?
        @@bot.api.send_message( chat_id: id_telegram, text: "No tiene ninguna tutoría.", parse_mode: "Markdown" )
      else
        text="Seleccione la tutoria que desea borrar:\n"
        fila_botones=Array.new
        array_botones=Array.new
        tutorias.each_with_index { |tutoria, index|
          puts tutoria.fecha
          puts tutoria.numero_peticiones
          text+= "\t (*#{index}*) \t Fecha tutoria: *#{tutoria.fecha.strftime('%a, %d %b %Y %H:%M:%S')}*\n"
          array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: index, callback_data: "borrar_tutoria_#{tutoria.fecha}")
          if array_botones.size == 3
            fila_botones << array_botones.dup
            array_botones.clear
          end
        }
        fila_botones << array_botones


        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
        @@bot.api.send_message( chat_id: id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )
      end
    else
      #todo
    end
  end



  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end

    if datos_mensaje =~ /borrar_tutoria_/

      datos_mensaje.slice! "borrar_tutoria_"
      fecha_tutoria=datos_mensaje[/[^_]*/]
      @profesor.borrar_tutoria(Tutoria.new(@profesor,fecha_tutoria))
      @@bot.api.answer_callback_query(callback_query_id: mensaje.obtener_identificador_mensaje, text: "Borrada!")
      @@bot.api.send_message( chat_id: id_telegram, text:   "Tutoria #{fecha_tutoria} borrada", parse_mode: "Markdown"  )
    else
      ejecutar(id_telegram)
    end

  end



  public_class_method :new

end