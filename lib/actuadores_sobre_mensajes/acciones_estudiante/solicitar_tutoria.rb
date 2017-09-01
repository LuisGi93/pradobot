require_relative '../accion'
require_relative '../../contenedores_datos/curso'
require_relative '../../contenedores_datos/estudiante'
require_relative '../../../lib/contenedores_datos/peticion'
require_relative '../menu_inline_telegram.rb'

  #
#  Clase que guía al usuario para que realiza la asistencia a una tutoría de un profesor 
  #    
class SolicitarTutoria < Accion
  @nombre = 'Realizar/Borrar petición tutoría'
  def initialize
    @fase = 'inicio'
    @tutorias = []
    @profesor_curso
    @ultimo_mensaje
  end

  #
#  Obtiene las tutorías que tiene disponible un estudiante 
  #    
  # * *Returns* :
  #   - Array de tutorías 
  #
  def obtener_tutorias_alumno
    profesor_curso = @curso.obtener_profesor_curso
    tutorias = profesor_curso.obtener_tutorias

    tutorias
  end

  # Muestra al usuario que le ha mando el mensaje las tutorías que tiene disponibles 
  #   # * *Args*    :
  #   - +opcion+ -> determina si se manda un nuevo mensaje o se edita el último enviado 
  def mostrar_tutorias(opcion)
    texto = "Seleccione la tutoria desea de #{@profesor_curso.nombre_usuario} son:\n"
    @tutorias.each_with_index do |tutoria, index|
      texto += "\t *#{index}*) \t Fecha tutoria: *#{tutoria.fecha}*, alumnos en cola: *#{tutoria.numero_peticiones}*\n"
    end
    array_tutorias = [*0..@tutorias.size - 1]
    menu = MenuInlineTelegram.crear_menu_indice(array_tutorias, 'Tutoria', 'final')
    if opcion == 'editar_mensaje'
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, reply_markup: menu, parse_mode: 'Markdown')
    else
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto, reply_markup: menu, parse_mode: 'Markdown')
    end
  end

  def reiniciar
    @tutorias.clear
    @profesor_curso = nil
  end

  #  Realiza una petición de asistencia a una tutoría 
  #   # * *Args*    :
  #   - +tutoria+ -> tutoria a la cual se realiza la petición de asistencia 
  def solicitar_tutoria(tutoria)
    peticion = Peticion.new(tutoria, Estudiante.new(@ultimo_mensaje.usuario.id_telegram))
      solicitud_aceptada = @profesor_curso.solicitar_tutoria(peticion)
      solicitud_aceptada
  end  

  #
  #   Implementa el método con el mismo nombre de link:Accion.html
  #    
  def recibir_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    datos_mensaje = @ultimo_mensaje.datos_mensaje
    case datos_mensaje
    when /\#\#\$\$Tutoria/
        datos_mensaje.slice! "#\#$$Tutoria"
        # fecha_tutoria=datos_mensaje[/[^_]*/].to_i
        acciones = ['Volver']
        menu = MenuInlineTelegram.crear(acciones)
        if solicitar_tutoria @tutorias.at(datos_mensaje.to_i)
          @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Recibido')
          @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, reply_markup: menu, text: "Solicitud para la tutoria #{@tutorias.at(datos_mensaje.to_i).fecha} registrada.", parse_mode: 'Markdown')
        else
          @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'No disponible')
          @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, reply_markup: menu, text: 'La tutoria elegida no está disponible, compruebe si ya ha solicitado para dicha sesión sino vuelva a intentarlo', parse_mode: 'Markdown')
        end
    when /\#\#\$\$Volver/
        mostrar_tutorias('editar_mensaje')
        @fase = ''
      else
        @profesor_curso = @curso.obtener_profesor_curso
        @tutorias = @profesor_curso.obtener_tutorias
        mostrar_tutorias('nuevo_mensaje')
    end
  end

  public_class_method :new
  private :solicitar_tutoria, :mostrar_tutorias, :obtener_tutorias_alumno
end
