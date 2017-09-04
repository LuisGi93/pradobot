
require 'telegram/bot'
require 'rspec'
require_relative 'spec_helper'

require_relative '../lib/actuadores_sobre_mensajes/crear_duda.rb'
require_relative '../lib/contenedores_datos/duda.rb'
require_relative '../lib/actuadores_sobre_mensajes/menu_dudas.rb'
describe CrearDuda do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuDudas.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)
  end

  it 'Cuando recibe el primer mensaje muestra mensaje explicativo de que realiza' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1.keys).to_not include(:reply_markup)
      expect(arg1[:text]).to eq("Escriba a continuación la duda que desea crear relacionada con *nombre del curso*:\n")
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe extraer el contenido de la duda del mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }
    expect(@stub_mensaje).to receive(:datos_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Contenido nueva duda')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe mandar mensaje que incluya el texto de la duda y el curso con opciones para confirmar la creación de la duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1.keys).to include(:chat_id, :text, :reply_markup)
      expect(arg1[:text]).to include('nombre del curso')
      expect(arg1[:text]).to include('Contenido nueva duda')
      expect(arg1[:reply_markup]).to be_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup)
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Si el mensaje indica crear la duda debe crearla duda en el curso activo' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }
    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'crear_duda_ 4' }
    usuario = double('usuario')
    allow(usuario).to receive(:id_telegram) { 1234 }
    allow(@stub_mensaje).to receive(:usuario) { usuario }

    allow(@stub_mensaje).to receive(:id_callback)
    allow(@stub_mensaje).to receive(:id_chat)
    allow(@stub_mensaje).to receive(:id_mensaje)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    expect(@stub_curso).to receive(:nueva_duda) { |arg1|
      expect(arg1).to be_instance_of Duda
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Los datos de la duda a crear en el curso deben ser los incluidos en el mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }
    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }

    expect(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }

    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'crear_duda_ 4' }
    usuario = double('usuario')
    allow(usuario).to receive(:id_telegram) { 1234 }

    expect(usuario).to receive(:id_telegram) { 1234 }

    allow(@stub_mensaje).to receive(:usuario) { usuario }
    allow(@stub_mensaje).to receive(:id_callback)
    allow(@stub_mensaje).to receive(:id_chat)
    allow(@stub_mensaje).to receive(:id_mensaje)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    expect(@stub_curso).to receive(:nueva_duda) { |arg1|
      expect(arg1.contenido).to eq('Contenido nueva duda')
      expect(arg1.usuario.id_telegram).to be(1234)
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Si el contenido del mensaje indica no crear la duda esta no debe crearse' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }
    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Contenido nueva duda' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'descartar_duda_ 4' }
    usuario = double('usuario')
    allow(usuario).to receive(:id_telegram) { 1234 }
    allow(@stub_mensaje).to receive(:usuario) { usuario }
    allow(@stub_mensaje).to receive(:id_callback)
    allow(@stub_mensaje).to receive(:id_chat)
    allow(@stub_mensaje).to receive(:id_mensaje)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    expect(@stub_curso).to_not receive(:nueva_duda)

    @accion.recibir_mensaje(@stub_mensaje)
  end
end
