require_relative 'spec_helper'

describe Mensaje do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:profesor].insert(id_telegram: 1111)
  end

  before(:each) do
    stub_mensaje=double('Mensaje')
    allow(stub_mensaje).to receive(:class) { Telegram::Bot::Types::Message }
    allow(stub_mensaje).to receive(:id) { 22 }
    allow(stub_mensaje).to receive(:text) { 'contenido' }
    allow(stub_mensaje).to receive_message_chain(:chat, :type) { 'group' }
    allow(stub_mensaje).to receive_message_chain(:chat, :id) { 33 }
    allow(stub_mensaje).to receive_message_chain(:chat, :title) { 'Titulo del chat' }
    allow(stub_mensaje).to receive(:message_id) { 44 }
    allow(stub_mensaje).to receive_message_chain(:from, :id) {  55 }
    allow(stub_mensaje).to receive_message_chain(:from, :first_name) { "nombre" }
    allow(stub_mensaje).to receive_message_chain(:from, :last_name) { "apellido" }
    @mensaje=Mensaje.new(stub_mensaje)
  end

  it 'Debe crear un usuario' do
    expect(@mensaje.usuario).to be_instance_of(Usuario)
  end

  it 'Debe extraer el contenido del mensaje correctamente' do
    expect(@mensaje.datos_mensaje).to eq('contenido')
  end
  it 'Debe extraer el identificador del mensaje' do
    expect(@mensaje.id_mensaje).to eq(44)
  end
  it 'Debe extraer el tipo de mensaje correctamente' do
    expect(@mensaje.tipo).to eq('mensaje_texto')
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