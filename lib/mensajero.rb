# encoding: UTF-8
#!/usr/bin/env ruby
require 'telegram/bot'
require 'sequel'
require_relative 'manejadores/manejador_mensajes_profesor'
require_relative 'manejadores/manejador_mensajes_grupales'
require_relative 'manejadores/manejador_mensajes_desconocido'

require_relative '../lib/mensaje'

class Mensajero

  attr_reader :token
  attr_accessor :bot
  def initialize(token)
    @bot=Telegram::Bot::Client;
    @token_bot_telegram=token
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @manejador_mensajes_profesor=ManejadorMensajesProfesor.new
    @manejador_mensajes_desconocido=ManejadorMensajesDesconocido.new
    @manejador_mensajes_grupales=ManejadorMensajesGrupales.new(@db)     #Puedo tener una clase hitos donde se guarden como cache todos los hitos de la asingatura y cuando se le pregutne al bot
                                                                      #por algun hito guarde todos los hitos para el curso tal y los borre a los 5 minutos.
  end


  private


  def obtener_tipo_usuario(id_telegram)
    usuario= @db[:usuario_telegram].where(:id_telegram => id_telegram).select(:rol_usuario).to_a
    if usuario_moodle.empty?
      tipo_usuario="desconocido"
    else
      tipo_usuario=usuario_moodle[0][:rol_usuario]
    end

  end

  def mensajes_chats_grupo mensaje
     @manejador_mensajes_grupales.recibir_mensaje(mensaje)
  end

  def mensajes_chats_privados mensaje
    id_telegram=mensaje.obtener_identificador_telegram
    tipo_usuario=obtener_tipo_usuario(id_telegram)
    puts tipo_usuario

    case tipo_usuario
      when "desconocido"
        @manejador_mensajes_desconocido.recibir_mensaje(mensaje)
      when "profesor_bot"
        @manejador_mensajes_profesor.recibir_mensaje(mensaje)

      when "alumno_bot"

      else


    end
  end

  public

  def empezar
    @bot.run(@token_bot_telegram) do |botox|
      Accion.establecer_bot(botox)
      Accion.establecer_db(@db)
      @manejador_mensajes_grupales.establecer_bot(botox)
      botox.listen do |message|
        begin
          mensaje=Mensaje.new(message)
          tipo_chat= mensaje.obtener_tipo_chat
          puts "tipo_chat #{tipo_chat}"
          if tipo_chat == "privado"
            mensajes_chats_privados(mensaje)
          elsif tipo_chat == "grupal"
            mensajes_chats_grupo(mensaje)
          end
        end
      end

    end
  end


end


