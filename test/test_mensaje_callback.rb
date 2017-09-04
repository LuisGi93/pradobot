require_relative 'spec_helper'

describe Mensaje do

  before(:each) do
    stub_mensaje=double('Mensaje')
    allow(stub_mensaje).to receive(:class) { Telegram::Bot::Types::CallbackQuery }
    allow(stub_mensaje).to receive_message_chain(:message,:message_id) { 11 }
    allow(stub_mensaje).to receive(:id) { 22 }
    allow(stub_mensaje).to receive(:data) { 'contenido' }
    allow(stub_mensaje).to receive_message_chain(:message,:chat, :type) { 'group' }
    allow(stub_mensaje).to receive_message_chain(:message,:chat, :id) { 33 }
    allow(stub_mensaje).to receive_message_chain(:message, :chat, :title) { 'Titulo del chat' }
    allow(stub_mensaje).to receive_message_chain(:from, :id) {  55 }
    allow(stub_mensaje).to receive_message_chain(:from, :first_name) { "nombre" }
    allow(stub_mensaje).to receive_message_chain(:from, :last_name) { "apellido" }
    allow(stub_mensaje).to receive(:class) { Telegram::Bot::Types::CallbackQuery }

    @mensaje=Mensaje.new(stub_mensaje)
  end

  it 'Debe crear un usuario' do
    expect(@mensaje.usuario).to be_instance_of(Usuario)
  end

  it 'Debe extraer el contenido del mensaje correctamente' do
    expect(@mensaje.datos_mensaje).to eq('contenido')
  end
  it 'Debe extraer el identificador del mensaje' do
    expect(@mensaje.id_mensaje).to eq(11)
  end
  it 'Debe extraer el tipo de mensaje correctamente' do
    expect(@mensaje.tipo).to eq('callbackquery')
  end
  it 'Debe normalizar el título del chat del que proce el mensaje' do
    expect(@mensaje.nombre_chat).to eq('Titulo Del Chat')
  end

  it 'Debe conocer el identificador de chat' do
    expect(@mensaje.id_chat).to eq(33)
  end

  it 'Debe saber de que tipo de chat procede el mensaje' do
    expect(@mensaje.tipo_chat).to eq('grupal')
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db.disconnect

  end
end