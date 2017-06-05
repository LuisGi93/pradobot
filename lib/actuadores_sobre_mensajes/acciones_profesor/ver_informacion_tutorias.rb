require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require 'active_support/inflector'
class VerInformacionTutorias < Accion

  @nombre='Ver información/cola solicitudes.'
  def initialize
    @id_telegram=nil
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    tutorias=@profesor.obtener_tutorias
    if tutorias.empty?
      @@bot.api.send_message( chat_id: id_telegram, text: "No tiene ninguna tutoría registrada en el sistema", parse_mode: "Markdown" )
    else
      text="Seleccione la tutoría de la cual  desea ver peticiones:\n"
      fila_botones=Array.new
      array_botones=Array.new
      tutorias.each_with_index { |tutoria, index|
        text+= "\t (*#{index}*) \t#{tutoria.fecha.strftime('%a, %d %b %Y %H:%M:%S')}\n"
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: index, callback_data: "tutoria_#{tutoria.fecha}")
        if array_botones.size == 3
          fila_botones << array_botones.dup
          array_botones.clear
        end
      }
      fila_botones << array_botones
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
      @@bot.api.send_message( chat_id: @id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )
    end


  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      @id_telegram=id_telegram
    end

    if datos_mensaje =~ /tutoria_/
      @@bot.api.answer_callback_query(callback_query_id: mensaje.obtener_identificador_mensaje, text: "Recibido!")
      datos_mensaje.slice! "tutoria_"
      tutoria=datos_mensaje[/[^_]*/]
      mostrar_peticiones tutoria
    else
      ejecutar(id_telegram)
    end


  end


  def reiniciar
    @id_telegram=nil
  end


  private
  def mostrar_peticiones fecha_tutoria

    tutoria=Tutoria.new(@profesor, fecha_tutoria)
    peticiones=tutoria.peticiones

    peticiones_aprobadas=Array.new
    peticiones.each{ |peticion|
      if(peticion.estado=="aceptada")
        peticiones_aprobadas << peticion
      end
    }

    if peticiones_aprobadas.empty?
      @@bot.api.send_message( chat_id: @id_telegram, text: "No ha aprobado ninguna petición para la tutoría elegida.", parse_mode: "Markdown" )
    else
      text="Cola asistencia tutoria:\n"
      peticiones_aprobadas.sort_by {|obj| obj.hora}
      peticiones_aprobadas.each{ |peticion|
          text+= "\t *#{contador}º* \tNombre telegram estudiante:\t *#{peticion.estudiante.nombre_usuario}\n*"
      }
      @@bot.api.send_message( chat_id: @id_telegram, text: text, parse_mode: "Markdown"  )
    end

  end









  public_class_method :new

end