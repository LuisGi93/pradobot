require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require_relative '../menu_inline_telegram'
require 'active_support/inflector'
class BorrarTutorias < Accion

  @nombre='Borrar tutoría.'
  def initialize selector_tutorias, tutoria
    @tutoria=tutoria
    @profesor=nil
    @selector_tutorias=selector_tutorias
  end

  def reiniciar
    @profesor=nil
    @ultimo_mensaje=nil
  end


  def generar_respuesta_mensaje  mensaje
      @ultimo_mensaje=mensaje
      respuesta_segun_datos_mensaje(@ultimo_mensaje.datos_mensaje)
  end

  def confirmar_borrado

      array_opciones=Array.new
      array_opciones << "Si"
      array_opciones << "No"
    menu=MenuInlineTelegram.crear(array_opciones)
    texto="¿Está seguro de que desea eliminar la tutoría con fecha en *#{@tutoria.fecha}*?"
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto , parse_mode: "Markdown", reply_markup: menu)
  end

 def respuesta_segun_datos_mensaje datos_mensaje
     puts datos_mensaje
    case datos_mensaje
      when  /\#\#\$\$Si/

     @profesor.borrar_tutoria(@tutoria)
    menu=MenuInlineTelegram.crear(Array.new << "Volver")
 @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: "Borrada!")
      @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: "Tutoria #{@tutoria.fecha} borrada.", parse_mode: "Markdown", reply_markup: menu)
      when /\#\#\$\$No/
          puts "Entro en el no"
        @selector_tutorias.reiniciar
        @selector_tutorias.solicitar_seleccion_tutoria "editar"
      else
          confirmar_borrado
      end




 end

  public_class_method :new

end
