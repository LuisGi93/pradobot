class Mensaje

  def initialize(mensaje)
    @mensaje=mensaje
  end
  def obtener_identificador_telegram()
    tipo_mensaje = @mensaje.class
    if (tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      id_telegram= @mensaje.message.from.id
    elsif (tipo_mensaje == Telegram::Bot::Types::Message)
      id_telegram=@mensaje.from.id
    end
  end

  def obtener_identificador_mensaje()
    tipo_mensaje = @mensaje.class
    if (tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      id_telegram= @mensaje.message.message_id
    elsif (tipo_mensaje == Telegram::Bot::Types::Message)
      id_telegram=@mensaje.message_id
    end
  end

  def obtener_datos_mensaje()
    tipo_mensaje = @mensaje.class

    if (tipo_mensaje == Telegram::Bot::Types::Message)
      return @mensaje.text
    end
  end
end