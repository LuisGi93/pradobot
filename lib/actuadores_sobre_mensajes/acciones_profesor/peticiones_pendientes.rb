require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require_relative '../menu_inline_telegram'
require 'active_support/inflector'
class PeticionesPendientesTutoria < Accion
  attr_accessor :teclado_menu_padre
  @nombre = 'Aprobar/Denegar peticiones.'
  def initialize(selector_tutorias, tutoria)
    @profesor = nil
    @selector_tutorias = selector_tutorias
    @tutoria = tutoria
    @peticiones = nil
    @peticion_elegida = nil
    @ultimo_mensaje = nil
  end

  #
  #  Dependiendo del contenido del mensaje manda un mensaje solicitando que se elija una tutoría o un menú para que apruebe o deniegue las peticiones de asistencia que ha recibido la tutoría activa.
  #     * *Args*    :
  #   - +mensaje+ -> mensaje recibido por el bot procedente de un usuario de Telegram  #
  #
  def generar_respuesta_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    datos_mensaje = @ultimo_mensaje.datos_mensaje
    if @profesor.nil?
      @profesor = Profesor.new(@ultimo_mensaje.usuario.id_telegram)
    end
    respuesta_segun_datos_mensaje(datos_mensaje)
  end

  #       Segun el contenido del mensaje envía un nuevo mensaje al usuario con información acerca de las peticiones que ha recibido la tutoría activa o con la opción de aceptar una petición a una tutoría o denegarla
  #         * *Args*    :
  #   - +datos_mensaje+ -> Contido del último mensaje recibido por el bot de Telegram.

  def respuesta_segun_datos_mensaje(datos_mensaje)
    if(@ultimo_mensaje.tipo=='callbackquery')
      case datos_mensaje
        when /\#\#\$\$Peticion /
          datos_mensaje.slice! "\#\#\$\$Peticion"
          id_estudiante_peticion = datos_mensaje[/[^_]*/].to_i
          solicitar_accion_sobre_peticion id_estudiante_peticion
          @fase = 'peticion_elegida'
        when /(\#\#\$\$Aceptar|\#\#\$\$Denegar)/
          aceptar_denegar_peticion(datos_mensaje)
        when /\#\#\$\$Volver/
          mostrar_menu_anterior
        else
          mostrar_peticiones_pendientes
          fase = 'mostrando_peticiones'
          end
    end
  end

  def reiniciar
    @profesor = nil
    @tutoria = nil
    @peticiones = nil
    @peticion_elegida = nil
  end

  private

  #    Envía un mensaje al usuario para que elija entre  todas aquellas peticiones que ha recibido la tutoría activa y que el profesor no ha dicho si las acepta

  def mostrar_peticiones_pendientes
    @peticiones = @tutoria.peticiones
    @peticiones_pendientes = []
    @peticiones.each do |peticion|
      @peticiones_pendientes << peticion if peticion.estado == 'por aprobar'
    end
    if @peticiones_pendientes.empty?
      menu = MenuInlineTelegram.crear([] << 'Volver')
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: 'No tiene peticiones para la tutoría elegida.', parse_mode: 'Markdown', reply_markup: menu)
    else

      texto = "Seleccione la petición la cual  desea aprobar/denegar:\n"
      contador = 0
      indices_peticiones = [*0..@peticiones_pendientes.size - 1]
      menu = MenuInlineTelegram.crear_menu_indice(indices_peticiones, 'Peticion', 'no_final')
      @peticiones_pendientes.each do |peticion|
        texto += "\t (*#{contador}*) \tNombre telegram estudiante:\t *#{peticion.estudiante.nombre_usuario}*\n"
        texto += "    Fecha realización petición: *\t#{peticion.hora.strftime('%d %b %Y %H:%M:%S')}* \n"
        contador += 1
      end
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, parse_mode: 'Markdown', reply_markup: menu)
    end
  end

  # Envía un mensaje al profesor pidiendo que elija si quiere aceptar esta petición o no.
  def solicitar_accion_sobre_peticion(pos_peticion)
    @peticion_elegida = @peticiones_pendientes[pos_peticion]
    if @peticion_elegida.nil?
      @@bot.api.send_message(chat_id: @profesor.id_telegram, text: 'Vuelva a intentarlo', parse_mode: 'Markdown')
    else
      text = "Petición seleccionada:\n"
      text += "\t Hora petición: *#{@peticion_elegida.hora}*\n"
      text += "\t Nombre usuario estudiante: #{@peticion_elegida.estudiante.nombre_usuario}"
      opciones = []
      opciones << 'Aceptar'
      opciones << 'Denegar'
      menu = MenuInlineTelegram.crear(opciones)
      @@bot.api.send_message(chat_id: @profesor.id_telegram, text: text, reply_markup: menu, parse_mode: 'Markdown')
    end
  end

  # Acepta o deniega la petición elegida por el usuario para la tutoría activa.
  #   * *Args*    :
  #   - +que_hacer+ -> Información contenida en el mensaje que se utiliza para saber si se acepta o deniega la petición.

  def aceptar_denegar_peticion(que_hacer)
    if que_hacer =~ /\#\#\$\$Aceptar/
      @peticion_elegida.aceptar
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Aceptada!')
      @@bot.api.send_message(chat_id: @profesor.id_telegram, text: 'Petición aceptada', parse_mode: 'Markdown')

    elsif que_hacer =~ /\#\#\$\$Denegar/
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Denegada')
      @@bot.api.send_message(chat_id: @profesor.id_telegram, text: 'Petición rechazada', parse_mode: 'Markdown')
      @peticion_elegida.denegar
    else
      @@bot.api.send_message(chat_id: @profesor.id_telegram, text: 'Error vuelva a intentarlo', reply_markup: markup, parse_mode: 'Markdown')
    end
    reiniciar
  end #  Dependiendo de que se ha hecho la última vez muestra el paso previo.

  #
  def mostrar_menu_anterior
    case @fase
    when 'peticion_elegida'
      mostrar_peticiones_pendientes
      @fase = 'mostrando_peticiones'
    else
      @selector_tutorias.reiniciar
      @selector_tutorias.solicitar_seleccion_tutoria 'editar'
      @fase = ''
    end
  end

  public_class_method :new
end
