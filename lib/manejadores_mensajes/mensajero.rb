# encoding: UTF-8
#!/usr/bin/env ruby
require 'telegram/bot'
require 'sequel'

require_relative 'encargado_mensajes_privados'
require_relative 'encargado_mensajes_grupales'
require_relative '../contenedores_datos/mensaje'


#
# Clase primera receptora de cualquier mensajes que provenga de Telegram hacia el bot, se encarga de dirigir estos mensajes
# dependiendo de si proceden de un chat grupal o privado.
#
class Mensajero

  def initialize(token)
    @bot=Telegram::Bot::Client;
    @token_bot_telegram=token
    @encargado_mensajes_privados=EncargadoMensajesPrivados.new
    @encargado_mensajes_grupales=EncargadoMensajesGrupales.new
  end


  private




  #
  # Destina los mensajes dependiendo de si provienen de un chat privado o grupal
  #
  # * *Args*    :
  #   - +mensaje+ -> un nuevo mensaje recibido por parte del bot
  #
  def clasificar_mensaje mensaje
    if mensaje.tipo_chat == "privado"
      @encargado_mensajes_privados.recibir_mensaje(mensaje)
    elsif mensaje.tipo_chat == "grupal"
      @encargado_mensajes_grupales.recibir_mensaje(mensaje)
    end
  end

  public

  #
  #Recibe los mensajes de parte de Telegram destinados al bot
  #
  def empezar_recibir_mensajes
puts @token_bot_telegram
puts @token_bot_telegram
    @bot.run(@token_bot_telegram) do |botox|
      puts botox.class.to_s
      Accion.establecer_bot(botox)
      @encargado_mensajes_privados.establecer_bot(botox)
      @encargado_mensajes_grupales.establecer_bot(botox)
      botox.listen do |message|
        begin
          mensaje=Mensaje.new(message)
          clasificar_mensaje(mensaje)
        end
      end
    end
  end


end
