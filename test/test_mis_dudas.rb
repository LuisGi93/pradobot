require_relative 'spec_helper'

describe ListarMisDudas do


  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')

    @db[:dudas].insert(id_usuario_duda: 1111, contenido_duda: 'contenido duda 1')

  end

  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 1111 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Mis dudas' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }

    @accion = MenuDudas.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)


    array_dudas_curso = []
    array_dudas_curso << Duda.new('contenido duda 1', UsuarioRegistrado.new(1111))
    array_dudas_curso << Duda.new('contenido duda 2', UsuarioRegistrado.new(2222))
    array_dudas_curso << Duda.new('contenido duda 3', UsuarioRegistrado.new(3333))

    allow(@stub_curso).to receive(:dudas) { array_dudas_curso }

    sut=double('sut')
    allow(sut).to receive_message_chain(:[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :send_message).and_return(sut)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query) { 1234 }




  end

  it 'Cuando recibe el primer mensaje debe mostrar las dudas del usuario' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    expect(@stub_bot).to receive_message_chain(:api, :send_message){|arg1|
      expect(arg1[:text]).to include('Sus dudas creadas para nombre del curso son', 'contenido duda 1')
      expect(arg1[:text]).to_not include('contenido duda 2', 'contenido duda 3')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db.disconnect

  end
end
