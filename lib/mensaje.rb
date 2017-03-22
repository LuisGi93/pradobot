require 'active_support/inflector'

class Mensaje

  def initialize(mensaje)
    @mensaje=mensaje
    @tipo_mensaje = @mensaje.class
  end
  def obtener_identificador_telegram()
    id_telegram= @mensaje.from.id
  end

  def obtener_identificador_mensaje()
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      id_telegram= @mensaje.message.message_id
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      id_telegram=@mensaje.message_id
    end
  end

  def obtener_datos_mensaje()
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      datos_mensaje= @mensaje.data
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      datos_mensaje= @mensaje.text
    end
  end

  def obtener_tipo_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      tipo_chat= @mensaje.message.chat.type
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      tipo_chat=@mensaje.chat.type
    end
    if tipo_chat == "group" || tipo_chat == "supergroup" || "channel"
      return "grupal"
    else
      return "privado"
    end
  end

  def obtener_identificador_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      tipo_chat= @mensaje.message.chat.id
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      tipo_chat=@mensaje.chat.id
    end

  end

  def obtener_nombre_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      tipo_chat= @mensaje.message.chat.title
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      tipo_chat=@mensaje.chat.title
    end
    return tipo_chat.titleize
  end

end