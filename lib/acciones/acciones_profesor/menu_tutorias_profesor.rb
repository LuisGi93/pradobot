require_relative  'establecer_tutorias'
require_relative 'peticiones_pendientes'
require_relative '../menu_acciones'
require_relative 'borrar_tutorias'
require_relative 'ver_informacion_tutorias'


class MenuTutoriasProfesor < MenuDeAcciones
  @nombre= 'Tutorías'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def ejecutar(id_telegram)
  kb= Array.new
  fila_botones=Array.new
  array_botones=Array.new
  @acciones.keys.each{
      |accion|
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
    array_botones << Telegram::Bot::Types::KeyboardButton.new( text: accion, )
    if array_botones.size == 2
      fila_botones << array_botones.dup
      array_botones.clear
    end
  }
  fila_botones << array_botones

  iniciar_acciones_defecto(fila_botones)

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: fila_botones)
    @@bot.api.send_message( chat_id: id_telegram, text: "Elija entre las acciones del menu",  reply_markup: markup)
    if(@acciones[AccionEstablecerTutorias.nombre].teclado_menu_padre.nil?)
      @acciones[AccionEstablecerTutorias.nombre].teclado_menu_padre=markup
    end
    return self
  end

  def obtener_accion_recibe_mensaje(datos_mensaje)
    siguiente_accion=nil


    puts "Los puneteros datos dle mensaje son #{datos_mensaje}"
    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
      if @accion_pulsada
        @accion_pulsada.reiniciar
      end
      @accion_pulsada=nil
    elsif datos_mensaje =~ /Volver al men/
      siguiente_accion=self
      puts "Lalalala"

      if @accion_pulsada
        @accion_pulsada.reiniciar
      end
      @accion_pulsada=nil
    else
      ha_pulsado_accion(datos_mensaje)
      if siguiente_accion.nil? && @accion_pulsada.nil?
        siguiente_accion=self
      else
        siguiente_accion=@accion_pulsada
      end
    end
    return siguiente_accion
  end

  def inicializar_acciones
    @acciones[AccionEstablecerTutorias.nombre] = AccionEstablecerTutorias.new
    @acciones[PeticionesPendientesTutoria.nombre] =PeticionesPendientesTutoria.new
    @acciones[BorrarTutorias.nombre]= BorrarTutorias.new
    @acciones[VerInformacionTutorias.nombre]= VerInformacionTutorias.new
  end
  private :inicializar_acciones

end