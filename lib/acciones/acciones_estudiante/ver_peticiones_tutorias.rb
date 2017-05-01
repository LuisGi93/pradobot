require_relative '../accion'
require_relative '../../usuarios/curso'
require_relative '../../usuarios/estudiante'

class VerPeticionesTutoria < Accion

  @nombre='Ver solicitudes realizadas'
  def initialize
    @fase='inicio'
    @tutorias=Array.new
    @profesores=Array.new
    @id_telegram=nil
  end


  def ejecutar(id_telegram)

    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    if @curso.size < 2
      estudiante=Estudiante.new(@id_telegram)
      peticiones=estudiante.obtener_peticiones_tutorias

      if peticiones.empty?
        @@bot.api.send_message( chat_id: id_telegram, text: "No ha realizado ninguna petición", parse_mode: "Markdown" )
      else
        profesor_curso=curso[0].obtener_profesor_curso
        text="Ha realizado las siguientes peticiones para las tutorias de *#{profesor_curso.nombre_usuario}:*\n"
        peticiones.each_with_index { |peticion, index|
          text+="\t *#{index})*:    Hora realizacion: *#{peticion.hora}*\n"
          text+="     Lugar en la cola: *#{peticion.tutoria.posicion_peticion(peticion)}*"
          text+="     Estado: *#{peticion.estado}*\n"
        }


        @@bot.api.send_message( chat_id: id_telegram, text: text, parse_mode: "Markdown"  )
      end
    else
      #todo
    end


  end


  def reiniciar
    @tutorias.clear
    @profesores.clear
    @id_telegram=nil
  end





  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    ejecutar(id_telegram)
  end



  public_class_method :new

end