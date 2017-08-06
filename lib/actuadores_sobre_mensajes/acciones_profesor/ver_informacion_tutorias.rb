require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require_relative '../menu_inline_telegram'
require 'active_support/inflector'
class VerInformacionTutorias < Accion

  @nombre='Ver información/cola solicitudes.'
  def initialize selector_tutorias, tutoria
    @ultimo_mensaje=nil
    @tutoria=tutoria
    @selector_tutorias=selector_tutorias
  end


  def reiniciar
    @ultimo_mensaje.usuario.id_telegram=nil
  end


  #
  #  Dependiendo del contenido del mensaje manda un mensaje solicitando que se elija una tutoría o información acerca de los alumnos en cola de la tutoría activa
  #     * *Args*    :
  #   - +mensaje+ -> mensaje recibido por el bot procedente de un usuario de Telegram  #

  def generar_respuesta_mensaje(mensaje)
    @ultimo_mensaje=mensaje
    datos_mensaje=@ultimo_mensaje.obtener_datos_mensaje
    if @profesor.nil?
      @profesor=Profesor.new(@ultimo_mensaje.usuario.id_telegram)
    end
    if @ultimo_mensaje.tipo == "callbackquery" && datos_mensaje=="#\#$$Volver"
      @selector_tutorias.solicitar_seleccion_tutoria("editar")
    else
      mostrar_peticiones
    end
  end

private

#  Muestra un mensaje con información acerca de la cola para la tutoría activa junto con una opción para volver al menú principal de tutorías.
#
  def mostrar_peticiones

    peticiones=@tutoria.peticiones

    peticiones_aprobadas=Array.new
    peticiones.each{ |peticion|
      if(peticion.estado=="aceptada")
        peticiones_aprobadas << peticion
      end
    }

    if peticiones_aprobadas.empty?
        menu=MenuInlineTelegram.crear(Array.new << "Volver")
        @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: "No ha aprobado ninguna petición para la tutoría elegida.", parse_mode: "Markdown", reply_markup: menu)
      #@@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: "No ha aprobado ninguna petición para la tutoría elegida.", parse_mode: "Markdown" )
    else
      texto="Cola asistencia tutoria:\n"
      peticiones_aprobadas.sort_by {|obj| obj.hora}
      peticiones_aprobadas.each{ |peticion|
          texto+= "\t *#{contador}º* \tNombre telegram estudiante:\t *#{peticion.estudiante.nombre_usuario}\n*"
      }
      @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text:  texto, parse_mode: "Markdown")
    end

  end




  public_class_method :new

end
