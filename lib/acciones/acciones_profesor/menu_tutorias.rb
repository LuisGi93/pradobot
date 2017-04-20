require_relative  'establecer_tutorias'
require_relative '../menu_acciones'


class MenuTutorias < MenuDeAcciones
  @nombre= 'Tutorias.'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def ejecutar(id_telegram)
    kb= Array.new
    @acciones.keys.each{
        |accion|
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
    }
    iniciar_acciones_defecto(kb)

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
    @@bot.api.send_message( chat_id: id_telegram, text: "Elija entre las acciones del menu",  reply_markup: markup)
    if(@acciones[AccionEstablecerTutorias.nombre].teclado_menu_padre.nil?)
      @acciones[AccionEstablecerTutorias.nombre].teclado_menu_padre=markup
    end
    return self
  end

  def obtener_siguiente_accion(datos_mensaje)
    siguiente_accion=nil

    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
      @accion_pulsada=nil
    elsif datos_mensaje =~ /Volver al menú/
      siguiente_accion=self
      @accion_pulsada.reiniciar
      @accion_pulsada=nil
    else
      accion_pulsada(datos_mensaje)

      if siguiente_accion.nil? && @accion_pulsada.nil?
        siguiente_accion=self

      else
        siguiente_accion=@accion_pulsada
      end
    end
    return siguiente_accion
  end

  def inicializar_acciones
    @acciones[AccionEstablecerTutorias.nombre] = AccionEstablecerTutorias.new()
  end
  private :inicializar_acciones

end