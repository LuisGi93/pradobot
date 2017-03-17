require_relative '../accion'

class Menu < Accion

  @acciones=nil

  def ejecutar(id_telegram)
    puts "Entro aqui"
    kb= Array.new
    @acciones.keys.each{
        |accion|

      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
    }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
    @@bot.api.send_message( chat_id: id_telegram, text: 'Elija que quiere hacer',  reply_markup: markup)
    return self
  end

  def accion_pulsada id_telegram,datos_mensaje
    accion=@acciones[datos_mensaje]
    if accion
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      @@bot.api.send_message(chat_id: id_telegram, text: datos_mensaje, reply_markup: kb)
    end
    return accion
  end

  def recibir_mensaje(mensaje)

    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje

    siguiente_accion=nil
    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
    else
      siguiente_accion=accion_pulsada(id_telegram,datos_mensaje)
      if siguiente_accion.nil?
        siguiente_accion=self
      end
    end
    siguiente_accion.ejecutar(id_telegram)

    return siguiente_accion
  end

  public_class_method :new
end