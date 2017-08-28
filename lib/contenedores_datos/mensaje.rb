require 'active_support/inflector'
require_relative 'usuario'
class Mensaje
  attr_reader :datos_mensaje, :tipo_chat, :id_chat, :nombre_chat, :tipo, :id_mensaje, :id_callback, :usuario
  def initialize(mensaje)
    @mensaje = mensaje
    if @mensaje.class == Telegram::Bot::Types::CallbackQuery
      @id_mensaje = @mensaje.message.message_id
      @id_callback = @mensaje.id
      @contenido = @mensaje.data
      @tipo = 'callbackquery'
      tipo_chat = @mensaje.message.chat.type
      @id_chat = @mensaje.message.chat.id
      @nombre_chat = @mensaje.message.chat.title
      @datos_mensaje = @mensaje.data

    elsif @mensaje.class == Telegram::Bot::Types::Message
      @tipo = 'mensaje_texto'
      @id_mensaje = @mensaje.message_id
      @contenido = @mensaje.text
      tipo_chat = @mensaje.chat.type
      @id_chat = @mensaje.chat.id
      @nombre_chat = @mensaje.chat.title
      @datos_mensaje = @mensaje.text
    end
    @usuario = Usuario.new(@mensaje.from.id, @mensaje.from.first_name + @mensaje.from.last_name)

    if tipo_chat == 'group' || tipo_chat == 'supergroup' || tipo_chat == 'channel'
      @tipo_chat = 'grupal'
      @nombre_chat = @nombre_chat.titleize
    else
      @tipo_chat = 'privado'
    end

    @tipo_mensaje = @mensaje.class
  end
end
