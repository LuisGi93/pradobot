require_relative 'accion'
require 'telegram/bot'


class Menu < Accion
  attr_reader :tipo

  @acciones=nil
  def initialize
    @accion_pulsada=nil
    @tipo=nil
  end

  def inicializar_acciones
    raise NotImplementedError.new
  end
  def cambiar_curso(curso)
    raise NotImplementedError.new
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
    return self
  end

  def accion_pulsada id_telegram,datos_mensaje
    raise NotImplementedError.new
  end

  def obtener_siguiente_accion(id_telegram, datos_mensaje)
    raise NotImplementedError.new
  end


  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso}", )
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras", )
  end


  public_class_method :new
  private :inicializar_acciones

end