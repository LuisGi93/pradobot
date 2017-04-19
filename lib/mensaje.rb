require 'active_support/inflector'

class Mensaje

  attr_reader :id_telegram, :datos_mensaje, :tipo_chat, :id_chat, :nombre_chat, :datos_mensaje
  def initialize(mensaje)
    @mensaje=mensaje
    @tipo_mensaje = @mensaje.class
    obtener_identificador_telegram
    obtener_tipo_chat
  end
  def obtener_identificador_telegram()
    @id_telegram= @mensaje.from.id
  end

  def obtener_identificador_mensaje()
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      @id_telegram= @mensaje.id
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      @id_telegram=@mensaje.message_id
    end
  end

  def obtener_nombre_usuario
      nombre=@mensaje.from.first_name+@mensaje.from.last_name
  end

  def obtener_datos_mensaje
    puts "El tipo de mensaje es #{@tipo_mensaje}"
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      @datos_mensaje= @mensaje.data
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      @datos_mensaje= @mensaje.text
    end
  end

  def obtener_tipo_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      @tipo_chat= @mensaje.message.chat.type
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      @tipo_chat=@mensaje.chat.type
    end
    if @tipo_chat == "group" || @tipo_chat == "supergroup" || @tipo_chat =="channel"
      return "grupal"
    else
      return "privado"
    end
  end

  def obtener_identificador_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      @id_chat= @mensaje.message.chat.id
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      @id_chat=@mensaje.chat.id
    end

  end

  def obtener_nombre_chat
    if (@tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
      @nombre_chat= @mensaje.message.chat.title
    elsif (@tipo_mensaje == Telegram::Bot::Types::Message)
      @nombre_chat=@mensaje.chat.title
    end
    @nombre_chat=@nombre_chat.titleize
  end

end