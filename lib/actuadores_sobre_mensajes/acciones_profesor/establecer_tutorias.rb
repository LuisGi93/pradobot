require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require 'active_support/inflector'

#
# Permite a un profesor la creación de una nueva tutoría 
#
class AccionEstablecerTutorias < Accion
  attr_accessor :teclado_menu_padre
  @nombre = 'Nueva tutoría'
  def initialize
    @fase = 'inicio'
    @datos = {}
    @ultimo_mensaje = nil
    @teclado_menu_padre = nil
  end

#
  # Envía un mensaje al profesor solicitandole que elija un día. 
#
  def solicitar_seleccion_dia
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup
             .new(keyboard: [%w[Lunes Martes], %w[Miércoles Jueves], %w[Viernes], 'Volver al menú de tutorias'], one_time_keyboard: true)

    @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: 'Elija el día de la semana en el que desea establecer la tutoría', reply_markup: markup, resize_keyboard: true)
    @fase = 'elegir_dia_semana'
  end

  #
  #   Implementa el método con el mismo nombre de link:Accion.html
  #    
  def recibir_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    case @fase
    when 'inicio'
      solicitar_seleccion_dia
    when 'elegir_dia_semana'

      if @ultimo_mensaje.datos_mensaje =~ /(Lunes|Martes|Miércoles|Jueves|Viernes|Volver al menú de tutorias)/
        @datos['dia_semana'] = @ultimo_mensaje.datos_mensaje

        texto = "Dia elegido *#{@ultimo_mensaje.datos_mensaje}*. Introduzca la hora de comienzo de las tutorías (hh:mm)(ej: 22:00 ó 5:00:00):"
        @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto, parse_mode: 'Markdown')
        @fase = 'hora_comienzo_tutorias'
              end
    when 'hora_comienzo_tutorias'
      if @ultimo_mensaje.datos_mensaje =~ /([012]\d:\d\d|[012]\d:\d\d:\d\d)/
        @datos['hora_comienzo_tutoria'] = @ultimo_mensaje.datos_mensaje
        crear_nueva_tutoria
        texto = "Tutoria establecida los *#{@datos['dia_semana']}* a las #{@ultimo_mensaje.datos_mensaje}"
        @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto, parse_mode: 'Markdown', reply_markup: @teclado_menu_padre)
        reiniciar
      else
        @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: 'Hora no válida vuelva a intentarlo', parse_mode: 'Markdown')

    end
    end
  end

  #
  #  Reinicia el estado interno de la acción 
  #    
  def reiniciar
    @fase = 'inicio'
    @datos.clear
  end

  private

  def fecha_proximo_dia_semana(dia_semana)
    dia_semana_a_numero = nil
    case dia_semana
    when 'Lunes'
      dia_semana_a_numero = 1
    when 'Martes'
      dia_semana_a_numero = 2
    when 'Miércoles'
      dia_semana_a_numero = 3
    when 'Jueves'
      dia_semana_a_numero = 4
    when 'Viernes'
      dia_semana_a_numero = 5
    end
    Date.today + ((dia_semana_a_numero - Date.today.wday) % 7)
  end

  def obtener_fecha_proxima_tutoria(dia_semana, hora)
    fecha = fecha_proximo_dia_semana(dia_semana)

    hora_partida = hora.split(':')
    hora_partida = hora.split(' ') if hora_partida.empty?
    if hora_partida.size < 3
      hora = Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    else
      hora = Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    end

    hora
  end

  def crear_nueva_tutoria
    profesor = Profesor.new(@ultimo_mensaje.usuario.id_telegram)

    fecha_tutoria = obtener_fecha_proxima_tutoria(@datos['dia_semana'], @datos['hora_comienzo_tutoria'])
    tutoria = Tutoria.new(profesor, fecha_tutoria)
    profesor.establecer_nueva_tutoria(tutoria)
  end

  public_class_method :new
  private :obtener_fecha_proxima_tutoria, :crear_nueva_tutoria, :solicitar_seleccion_dia, :obtener_fecha_proxima_tutoria
end
