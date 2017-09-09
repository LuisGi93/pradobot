
require_relative 'borrar_tutorias'
require_relative 'peticiones_pendientes'
require_relative 'ver_informacion_tutorias'
require_relative '../menu_inline_telegram'

#
# Esta clase es como una especie de proxy entre menu_tutorias y las acciontes borrar, pendientes e informacion. Se encarga de elegir cual es la tutoría sobre la cual actuan los mensajes del usuario y de cambiar la acción que recibe los mensajes que puede ser las acciones mencionadas anteriomente.
#

class AccionSobreTutoria < Accion
  attr_accessor :tutoria
  @nombre = 'Gestionar tutorías'
  def initialize
    @tutorias = []
    @tutoria = nil
    @ultimo_mensaje = nil
  end

  #
  # Envia un mensaje solicitando que escoja una tutoría para lo cual muestra un menu tipo inline con las tutorías que ha creado el usuario.
  #  * *Args*    :
  #   - +modo+ -> Si es editar no manda un nuevo mensaje al chat del usuario sino que lo actualiza  para que muestre las tutorias del usuario.
  #
  def solicitar_seleccion_tutoria(modo)
    @accion = nil
      @tutoria = nil
      if @tutorias.nil? || @tutorias.empty?
        @tutorias = Profesor.new(@ultimo_mensaje.usuario.id_telegram).obtener_tutorias
      end

      mensaje = ''
      if @tutorias.nil? || @tutorias.empty?
        mensaje = 'No tiene ninguna tutoría creada.'
        @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: mensaje, parse_mode: 'Markdown')

      else
        indices_tutoria = [*0..@tutorias.size - 1]
          indices_menu = MenuInlineTelegram.crear_menu_indice(indices_tutoria, 'tutoria', 'final')
          @tutorias.each_with_index do |tutoria, index|
            mensaje += "\n\t (*#{index}*) \t Fecha tutoría: *#{tutoria.fecha}*     \n"
          end

          puts mensaje
          if modo.eql?('editar')
            @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: mensaje, parse_mode: 'Markdown', reply_markup: indices_menu)
          else

            @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: mensaje.to_s, reply_markup: indices_menu, parse_mode: 'markdown')
        end
      end

  end  

  def recibir_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    if @accion
      @accion.generar_respuesta_mensaje(mensaje)
    else
      respuesta_segun_accion_pulsada
    end
  end

  def reiniciar
    @accion = nil
    @tutoria = nil
    @tutorias=nil
  end

  #  Muestra un menu tipo inline en el chat dle usuario con las opciones "Peticiones pendientes de aceptar", "Cola alumnos", "Borrar tutoria", "Volver"
#
  def mostrar_opciones_tutoria
      acciones = ['Peticiones pendientes de aceptar', 'Cola alumnos', 'Borrar tutoría', 'Volver']
      menu = MenuInlineTelegram.crear(acciones)
      texto = "Tutoría elegida #{@tutoria.fecha}. Elija que desea hacer:"
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, reply_markup: menu, parse_mode: 'Markdown')
    end

  #
# Segun los datos recibidos del mensaje establece una nueva acción activa que recibirá los sucesivos mensajes.
  # # * *Args*    :
#   - +datos_mensaje+ -> cadena de carácteres que determina la proxima acción activa

  def respuesta_segun_accion_pulsada()
    if(@ultimo_mensaje.tipo=='callbackquery')
      datos_mensaje=@ultimo_mensaje.datos_mensaje
      case @ultimo_mensaje.datos_mensaje
        when /\#\#\$\$tutoria/
               datos_mensaje.slice! "#\#$$tutoria"
               indice_tutoria = datos_mensaje.to_i
               puts datos_mensaje
               puts indice_tutoria
               puts @tutorias.to_s
               @tutoria = @tutorias.at(indice_tutoria)
               mostrar_opciones_tutoria
        when /\#\#\$\$Borrar tutoría/
              @accion = BorrarTutorias.new(self, @tutoria)
              @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Cola alumnos/
              @accion = VerInformacionTutorias.new(self, @tutoria)
              @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Peticiones pendientes de aceptar/
              @accion = PeticionesPendientesTutoria.new(self, @tutoria)
              @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Volver/
              solicitar_seleccion_tutoria 'editar'
          else
            solicitar_seleccion_tutoria 'nuevo'
      end
    else
      solicitar_seleccion_tutoria 'nuevo'
    end
  end

  public_class_method :new
end
