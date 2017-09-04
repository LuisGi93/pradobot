require_relative 'spec_helper'

describe MenuChat do
  before(:each) do
    @stub_bot = double('bot')
    allow(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /Introduzca el nombre del chat al cual quiere asociar .*/))

    Accion.establecer_bot(@stub_bot)
    @accion = AccionAsociarChat.new

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Asociar chat curso' }

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    @stub_padre = double('accion_padre')
    allow(@stub_padre).to receive(:ejecutar)
    allow(@stub_padre).to receive(:cambiar_curso)
    allow(@stub_padre).to receive(:cambiar_curso_parientes)
    allow(@stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuChat.new(@stub_padre)
    @accion.cambiar_curso(@stub_curso)

end



  it 'Profesor debe poder elegir la opción de Asignar chat a curso' do

    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /Introduzca el nombre del chat al cual quiere asociar .*/))

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'No marca como pulsada una opción mientras no se seleccione ninguna' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'datos aleatorios' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to_not  include('Introduzca el nombre del chat al cual quiere asociar')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Debe dejar retroceder al menú anterior' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe dejar retroceder al menú anterior incluso si hay una opción pulsada' do

    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /Introduzca el nombre del chat al cual quiere asociar .*/))

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)


    @accion.recibir_mensaje(@stub_mensaje)
  end

end