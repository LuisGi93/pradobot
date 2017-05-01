require_relative '../accion'
require_relative '../../usuarios/tutoria'
require 'active_support/inflector'
class VerInformacionTutorias < Accion

  attr_accessor :teclado_menu_padre
  @nombre='Ver información/cola solicitudes.'
  def initialize
    @profesor=nil
    @tutoria=nil
    @peticiones=nil
    @peticion_elegida=nil
    @id_telegram=nil
  end

  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
    @profesor=Profesor.new(id_telegram)
  end

  def ejecutar(id_telegram)

    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    if @curso.size < 2
      tutorias=@profesor.obtener_tutorias
      puts tutorias.to_s
      if tutorias.empty?
        @@bot.api.send_message( chat_id: id_telegram, text: "No tiene ninguna tutoría registrada en el sistema", parse_mode: "Markdown" )
      else
        text="Seleccione la tutoria de la cual  desea ver peticiones:\n"
        fila_botones=Array.new
        array_botones=Array.new
        tutorias.each_with_index { |tutoria, index|
          text+= "\t *#{index}* \t#{tutoria.fecha}"
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
    else
      #todo
    end
    @fase="seleccion_tutoria"
  end


  def reiniciar
    @profesor=nil
    @tutoria=nil
    @peticiones=nil
    @peticion_elegida=nil
    @id_telegram=nil
  end


  def mostrar_peticiones fecha_tutoria

    @tutoria=Tutoria.new(@profesor, fecha_tutoria)
    @peticiones=@tutoria.peticiones

    if @peticiones.empty?
      @@bot.api.send_message( chat_id: @id_telegram, text: "No ha aprobado ninguna petición para la tutoría elegida.", parse_mode: "Markdown" )
    else
      text="Historial de peticiones:\n"
      fila_botones=Array.new
      array_botones=Array.new
      contador=0
      @peticiones.sort
      @peticiones.each{ |peticion|
        if(peticion.estado=="aceptada")
          text+= "\t *#{contador}º* \tNombre telegram estudiante:\t#{peticion.estudiante.nombre_usuario}\n"
          text+= "    Hora petición: \t#{peticion.hora}"
          array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: contador, callback_data: "peticion_#{peticion.estudiante.id}")
          if array_botones.size == 3
            fila_botones << array_botones.dup
            array_botones.clear
          end
          contador+=1
        end
      }
      fila_botones << array_botones
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
      @@bot.api.send_message( chat_id: @id_telegram, text: text, parse_mode: "Markdown"  )
    end

  end







  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
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



  public_class_method :new

end