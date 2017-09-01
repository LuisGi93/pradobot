require_relative '../accion'
require_relative '../../contenedores_datos/curso'
require_relative '../../contenedores_datos/estudiante'

#
#Clase que muestra al usuario las peticiones que ha realizado a las tutoras
##
class VerPeticionesTutoria < Accion
  @nombre = 'Ver solicitudes realizadas'
  def initialize
    @ultimo_mensaje = nil
  end  

  def reiniciar
    @ultimo_mensaje = nil
  end 

  #
  #   Implementa el método con el mismo nombre de link:Accion.html
  #    
  def recibir_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    estudiante = Estudiante.new(@ultimo_mensaje.usuario.id_telegram)
    peticiones = estudiante.obtener_peticiones_tutorias

    puts peticiones.empty?
    puts peticiones.to_s
    if peticiones.empty?
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: 'No ha realizado ninguna petición', parse_mode: 'Markdown')
    else
      profesor_curso = @curso.obtener_profesor_curso
      text = "Ha realizado las siguientes peticiones para las tutorias de *#{profesor_curso.nombre_usuario}:*\n"
      peticiones.each_with_index do |peticion, index|
        text += "\t *#{index})*:  Hora realizacion: *#{peticion.hora}*\n"
        text += "         Lugar en la cola: *#{peticion.tutoria.posicion_peticion(peticion)}*"
        text += "         Estado: *#{peticion.estado}*\n"
      end
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: text, parse_mode: 'Markdown')
    end
  end

  public_class_method :new
end
