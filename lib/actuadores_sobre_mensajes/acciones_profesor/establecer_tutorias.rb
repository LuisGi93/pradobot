require_relative '../accion'
require_relative '../../contenedores_datos/tutoria'
require 'active_support/inflector'
class AccionEstablecerTutorias < Accion

  attr_accessor :teclado_menu_padre
  @nombre='Establecer nueva tutoria.'
  def initialize
    @fase='inicio'
    @datos=Hash.new
    @id_telegram=nil
    @teclado_menu_padre=nil
  end


  def ejecutar(id_telegram)

    if @id_telegram.nil?
      @id_telegram=id_telegram
    end
    markup=Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: [%w(Lunes Martes), %w(Miércoles Jueves), %w(Viernes), "Volver al menú de tutorias"], one_time_keyboard: true)

    @@bot.api.send_message( chat_id: id_telegram, text: "Elija el dia de la semana en el que desea establecer la tutoria",  reply_markup: markup, resize_keyboard: true )
    @fase='elegir_dia_semana'
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.usuario.id_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      @id_telegram=id_telegram
    end

    case @fase
      when 'inicio'
        ejecutar(id_telegram)
      when 'elegir_dia_semana'      #$Hay que chequear que meta Lunes, Martes, Miercoles.. y de mientras no cambiar de fase
        @datos['dia_semana']=datos_mensaje

        texto="Dia elegido *#{datos_mensaje}*. Introduzca la hora de comienzo de las tutorías (hh:mm)(ej: 22:00 ó 5:00:00):"
        @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
        @fase='hora_comienzo_tutorias'
      when 'hora_comienzo_tutorias'
        @datos['hora_comienzo_tutoria']=datos_mensaje
        crear_nueva_tutoria
        texto="Tutoria establecida los *#{@datos['dia_semana']}* a las #{datos_mensaje}"
        @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown',  reply_markup:@teclado_menu_padre )
        reiniciar
    end

  end

  def reiniciar
    @fase='inicio'
    @datos.clear
  end

  private



  def fecha_proximo_dia_semana dia_semana
    dia_semana_a_numero=nil
    case dia_semana
      when 'Lunes'
        dia_semana_a_numero=1
      when 'Martes'
        dia_semana_a_numero=2
      when 'Miércoles'
        dia_semana_a_numero=3
      when 'Jueves'
        dia_semana_a_numero=4
      when 'Viernes'
        dia_semana_a_numero=5
    end
    return Date.today + ((dia_semana_a_numero - Date.today.wday) % 7)
  end

  def obtener_fecha_proxima_tutoria dia_semana, hora

    fecha=fecha_proximo_dia_semana(dia_semana)

    hora_partida=hora.split(":")
    if hora_partida.empty?
      hora_partida=hora.split(" ")
    end
    if hora_partida.size < 3
      hora= Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    else
      hora= Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    end

    return hora
  end


  def crear_nueva_tutoria
    profesor=Profesor.new(@id_telegram)

    fecha_tutoria=obtener_fecha_proxima_tutoria(@datos['dia_semana'], @datos['hora_comienzo_tutoria'])
    tutoria=Tutoria.new(profesor,fecha_tutoria)
    puts fecha_tutoria
    profesor.establecer_nueva_tutoria(tutoria)
  end





  public_class_method :new

end
