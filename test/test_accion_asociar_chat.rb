require 'rspec'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/accion_asociar_chat'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_chat'

describe AccionAsociarChat do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)
    @accion = AccionAsociarChat.new

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    #    curso=Curso.new(5, "nombre_chat")
    #
    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuChat.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)
    # @accion.recibir_mensaje("Asociar chat curso")
    # @accion.curso=@stub_curso
  end

  it 'Cuando recibe el primer mensaje muestra mensaje explicativo de que realiza' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Asociar chat curso' }
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /Introduzca el nombre del chat al cual quiere asociar .*/))
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Si no existe un chat con el nombre introducido por el profesor este debe crearse en la base de datos' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Asociar chat curso' }

    allow(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /Introduzca el nombre del chat al cual quiere asociar .*/))
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nombre chat' }

    expect(@stub_curso).to receive(:asociar_chat).with('Nombre chat') { true }
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /^Curso.* asociado al chat/))

    @accion.recibir_mensaje(@stub_mensaje)
  end
end
