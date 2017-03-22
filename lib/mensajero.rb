# encoding: UTF-8
#!/usr/bin/env ruby
require 'telegram/bot'
require 'sequel'
require_relative 'manejadores/manejador_mensajes_profesor'
require_relative '../lib/mensaje'
class Mensajero

  attr_reader :token
  attr_accessor :bot
  def initialize(token)
    @bot=Telegram::Bot::Client;
    @token_bot_telegram=token
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @manejador_mensajes_profesor=ManejadorMensajesProfesor.new

  end


  def obtener_tipo_usuario(id_telegram)
    usuario_moodle= @db[:usuarios_telegram].where(:id_telegram => id_telegram).select(:tipo_usuario).to_a
    if usuario_moodle.empty?
      tipo_usuario="desconocido"
    else
      tipo_usuario=usuario_moodle[0][:tipo_usuario]
    end

  end

  def mensajes_chats_grupo mensaje

  end

  def mensajes_chats_privados mensaje

  end

  def empezar
    @bot.run(@token_bot_telegram) do |botox|
      Accion.establecer_bot(botox)
      Accion.establecer_db(@db)
      botox.listen do |message|
        begin
          mensaje=Mensaje.new(message)
          id_telegram=mensaje.obtener_identificador_telegram
          tipo_usuario=obtener_tipo_usuario(id_telegram)
          puts tipo_usuario

          case tipo_usuario
            when "desconocido"

            when "administrador"

            when "profesor"
              @manejador_mensajes_profesor.recibir_mensaje(mensaje,botox)

            when "alumno"

            else


          end


        end
    end

      end
  end



  def validez_token
    @bot.run(@token) do |botox|
      return botox.api.get_me
    end
  end


end


