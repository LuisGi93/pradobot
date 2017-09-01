require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require_relative '../menu_inline_telegram'
require 'active_support/inflector'

# Clase que engloba la accion borrar una tutoria. 
class BorrarTutorias < Accion
  @nombre = 'Borrar tutoría.'
  def initialize(selector_tutorias, tutoria)
    @tutoria = tutoria
    @selector_tutorias = selector_tutorias
  end

  def reiniciar
    @ultimo_mensaje = nil
  end

  def generar_respuesta_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    respuesta_segun_datos_mensaje(@ultimo_mensaje.datos_mensaje)
  end
  # Envía un mensaje al profesor pidiendo que confirme el borrado de la duda seleccionada 

  def confirmar_borrado
    array_opciones = []
    array_opciones << 'Si'
    array_opciones << 'No'
    menu = MenuInlineTelegram.crear(array_opciones)
    texto = "¿Está seguro de que desea eliminar la tutoría con fecha en *#{@tutoria.fecha}*?"
    @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, parse_mode: 'Markdown', reply_markup: menu)
  end

  # Realiza una acción según el botón pulsado por el profesor 
  def respuesta_segun_datos_mensaje(datos_mensaje)
    case datos_mensaje
    when /\#\#\$\$Si/
      profesor=Profesor.new(@ultimo_mensaje.usuario.id_telegram)
      profesor.borrar_tutoria(@tutoria)
      menu = MenuInlineTelegram.crear([] << 'Volver')
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Borrada!')
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: "Tutoria #{@tutoria.fecha} borrada.", parse_mode: 'Markdown', reply_markup: menu)
    when /\#\#\$\$No/
      puts 'Entro en el no'
      @selector_tutorias.reiniciar
      @selector_tutorias.solicitar_seleccion_tutoria 'editar'
    else
      confirmar_borrado
      end
  end

  public_class_method :new
end
