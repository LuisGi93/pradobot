# encoding: UTF-8
#!/usr/bin/env ruby
require 'telegram/bot'
require 'sequel'
require_relative 'manejadores/manejador_mensajes_profesor'
require_relative 'manejadores/manejador_mensajes_grupales'
require_relative 'manejadores/manejador_mensajes_desconocido'
require_relative 'manejadores/manejador_mensajes_estudiante'

require_relative '../lib/mensaje'

class Mensajero

  attr_reader :token
  attr_accessor :bot
  def initialize(token)
    @bot=Telegram::Bot::Client;
    @token_bot_telegram=token
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @manejador_mensajes_profesor=ManejadorMensajesProfesor.new
    @manejador_mensajes_estudiante=ManejadorMensajesEstudiante.new(@db)
    @manejador_mensajes_desconocido=ManejadorMensajesDesconocido.new
    @manejador_mensajes_grupales=ManejadorMensajesGrupales.new(@db)     #Puedo tener una clase hitos donde se guarden como cache todos los hitos de la asingatura y cuando se le pregutne al bot
                                                                      #por algun hito guarde todos los hitos para el curso tal y los borre a los 5 minutos.
  end


  private


  def obtener_tipo_usuario(id_telegram)
    usuario= @db[:usuario_telegram].where(:id_telegram => id_telegram).first
    tipo_usuario="desconocido"
    if usuario
      es_profesor=@db[:profesor].where(:id_telegram => id_telegram).first
      if es_profesor
        tipo_usuario='profesor'
      else
        es_estudiante=@db[:estudiante].where(:id_telegram => id_telegram).first
        if es_estudiante
          tipo_usuario='estudiante'
        else
          es_admin=@db[:admin].where(:id_telegram => id_telegram).first
            if es_admin
              tipo_usuario='admin'
            end
        end
      end
    end
    return tipo_usuario

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
      when "profesor"
        @manejador_mensajes_profesor.recibir_mensaje(mensaje)

      when "estudiante"
        @manejador_mensajes_estudiante.recibir_mensaje(mensaje)

      when "admin"
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


