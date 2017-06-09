require_relative '../accion'
require_relative '../../contenedores_datos/curso'
require_relative '../../contenedores_datos/estudiante'

class VerPeticionesTutoria < Accion

  @nombre='Ver solicitudes realizadas'
  def initialize
    @ultimo_mensaje=nil
  end



  def reiniciar
    @ultimo_mensaje.id_telegram=nil
  end



  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje
    id_telegram=mensaje.obtener_identificador_telegram
    estudiante=Estudiante.new(@ultimo_mensaje.id_telegram)
    peticiones=estudiante.obtener_peticiones_tutorias

    if peticiones.empty?
      @@bot.api.send_message( chat_id: id_telegram, text: "No ha realizado ninguna petición", parse_mode: "Markdown" )
    else
      profesor_curso=@curso.obtener_profesor_curso
      text="Ha realizado las siguientes peticiones para las tutorias de *#{profesor_curso.nombre_usuario}:*\n"
      peticiones.each_with_index { |peticion, index|
        text+="\t *#{index})*:  Hora realizacion: *#{peticion.hora}*\n"
        text+="         Lugar en la cola: *#{peticion.tutoria.posicion_peticion(peticion)}*"
        text+="         Estado: *#{peticion.estado}*\n"
      }
      @@bot.api.send_message( chat_id: id_telegram, text: text, parse_mode: "Markdown"  )
    end

  end



  public_class_method :new

end