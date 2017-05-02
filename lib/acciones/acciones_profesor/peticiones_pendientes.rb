require_relative '../accion'
require_relative '../../usuarios/tutoria'
require 'active_support/inflector'
class PeticionesPendientesTutoria < Accion

  attr_accessor :teclado_menu_padre
  @nombre='Aprobar/Denegar peticiones.'
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
      profesor_curso=curso[0].obtener_profesor_curso
      tutorias=profesor_curso.obtener_tutorias
      puts tutorias.to_s
      if tutorias.empty?
        @@bot.api.send_message( chat_id: id_telegram, text: "El profesor *#{profesor_curso.nombre_usuario}* a cargo de *#{curso[0].nombre}* no tiene tutorias", parse_mode: "Markdown" )
      else
        text="Seleccione la tutoria de la cual  desea aprobar/denegar peticiones:\n"
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


  def mostrar_peticiones_pendientes fecha_tutoria

    @tutoria=Tutoria.new(@profesor, fecha_tutoria)
    @peticiones=@tutoria.peticiones
    peticiones_pendientes=Array.new
    @peticiones.each{ |peticion|
      if(peticion.estado=="por aprobar")
      peticiones_pendientes << peticion
      end
    }
      if peticiones_pendientes.empty?
        @@bot.api.send_message( chat_id: @id_telegram, text: "No tiene peticiones para la tutoría elegida.", parse_mode: "Markdown" )
      else
        text="Seleccione la petición la cual  desea aprobar/denegar:\n"
        fila_botones=Array.new
        array_botones=Array.new
        contador=0
        peticiones_pendientes.each{ |peticion|
            text+= "\t (*#{contador}*) \tNombre telegram estudiante:\t *#{peticion.estudiante.nombre_usuario}*\n"
            text+= "    Fecha realización petición: *\t#{peticion.hora.strftime('%d %b %Y %H:%M:%S')}* \n"
            array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: contador, callback_data: "peticion_#{peticion.estudiante.id}")
            if array_botones.size == 3
              fila_botones << array_botones.dup
              array_botones.clear
            end
            contador+=1
        }
        fila_botones << array_botones
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
        @@bot.api.send_message( chat_id: @id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )
      end

  end


  def solicitar_accion_sobre_peticion id_estudiante_peticion

    #Nose si buscarlo en @peticiones o en donde @peticion=Peticion.new(@tutoria,Estudiante.new(id),  fecha_tutoria)
    @peticion_elegida=nil
    cont=0
    while(@peticion_elegida.nil? && cont < @peticiones.size)
      if @peticiones[cont].estudiante.id.to_i== id_estudiante_peticion.to_i
        @peticion_elegida=@peticiones[cont]

      end
      cont+=1
    end
    if @peticion_elegida.nil?
      @@bot.api.send_message( chat_id: id_telegram, text: "Vuelva a intentarlo", parse_mode: "Markdown" )
    else
      text="Petición seleccionada:\n"
      text+="\t Hora petición: *#{@peticion_elegida.hora}*\n"
      text+="\t Nombre usuario estudiante: #{@peticion_elegida.estudiante.nombre_usuario}"
      fila_botones=Array.new
      array_botones=Array.new
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Aceptar", callback_data: "aceptar_peticion###{@peticion_elegida.estudiante.id}")
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Denegar", callback_data: "denegar_peticion###{@peticion_elegida.estudiante.id}")

      fila_botones << array_botones
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
      @@bot.api.send_message( chat_id: @id_telegram, text: text,reply_markup: markup, parse_mode: "Markdown"  )
    end

  end


  def aceptar_denegar_peticion  id_mensaje, que_hacer

    if que_hacer =~ /aceptar_peticion##/
      @peticion_elegida.aceptar
      @@bot.api.answer_callback_query(callback_query_id: id_mensaje, text: "Aceptada!")
      @@bot.api.send_message( chat_id: @id_telegram, text: "Petición aceptada", parse_mode: "Markdown"  )

    elsif que_hacer =~ /denegar_peticion##/
      @@bot.api.answer_callback_query(callback_query_id: id_mensaje, text: "Denegada")
      @@bot.api.send_message( chat_id: @id_telegram, text: "Petición rechazada", parse_mode: "Markdown"  )
      @peticion_elegida.denegar
    else
      @@bot.api.send_message( chat_id: @id_telegram, text: "Error vuelva a intentarlo",reply_markup: markup, parse_mode: "Markdown"  )
    end
    reiniciar
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
      mostrar_peticiones_pendientes tutoria
    elsif datos_mensaje =~ /peticion_/
      datos_mensaje.slice! "peticion_"
      id_estudiante_peticion=datos_mensaje[/[^_]*/]
      solicitar_accion_sobre_peticion id_estudiante_peticion
    elsif datos_mensaje =~ /(aceptar_peticion##|denegar_peticion##)/
      aceptar_denegar_peticion(mensaje.obtener_identificador_mensaje, datos_mensaje)
    else
      ejecutar(id_telegram)
    end


  end



  public_class_method :new

end