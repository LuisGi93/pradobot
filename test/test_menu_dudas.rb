require_relative 'spec_helper'

describe MenuDudas do

  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')

    @db[:dudas].insert(id_usuario_duda: 1111, contenido_duda: 'contenido duda 1')
    @db[:dudas].insert(id_usuario_duda: 1111, contenido_duda: 'contenido duda 7')

  end

  before(:each) do

    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }
    @stub_padre = double('accion_padre')
    allow(@stub_padre).to receive(:ejecutar)
    allow(@stub_padre).to receive(:cambiar_curso)
    allow(@stub_padre).to receive(:cambiar_curso_parientes)
    allow(@stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuDudas.new(@stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 1111 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }


    allow(@stub_usuario2).to receive(:id_telegram) { 12 }
    allow(@stub_usuario2).to receive(:nombre_usuario) { 'usuario2' }


    @stub_duda = double('duda2')
    allow(@stub_duda).to receive(:contenido) { 'contenido duda 2' }
    allow(@stub_duda).to receive(:usuario) { @stub_usuario2 }
    stub_respuesta = double('respuesta')
    allow(stub_respuesta).to receive(:contenido) { 'Contenido de la solución de la duda' }
    allow(@stub_duda).to receive(:solucion) { stub_respuesta }

    dudas_sin = []
    dudas_sin << Duda.new('contenido duda 1', UsuarioRegistrado.new(1111))
    dudas_sin << Duda.new('contenido duda 2', @stub_usuario2)

    dudas_con = []
    dudas_con << Duda.new('contenido duda 7', UsuarioRegistrado.new(1111))
    dudas_con << Duda.new('contenido duda 8', @stub_usuario2)

    dudas_mis = []
    dudas_mis << Duda.new('contenido duda 1', UsuarioRegistrado.new(1111))
    dudas_mis << Duda.new('contenido duda 7', UsuarioRegistrado.new(1111))

    allow(@stub_curso).to receive(:obtener_dudas_sin_resolver) { dudas_sin}
    allow(@stub_curso).to receive(:obtener_dudas_resueltas) { dudas_con}
    allow(@stub_curso).to receive(:dudas) { dudas_mis}

    allow(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :delete_message)
  end

  it 'Usuario debe poder elegir ver sus dudas' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Mis dudas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Sus dudas creadas para nombre del curso son','contenido duda 1','contenido duda 7')
      expect(arg1[:text]).to_not include('contenido duda 2', 'contenido duda 8')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Usuario debe poder elegir ver las dudas resueltas del curso' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Resueltas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas resueltas para nombre del curso son','contenido duda 7', 'contenido duda 8')
      expect(arg1[:text]).to_not include('contenido duda 1', 'contenido duda 2')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Usuario debe poder elegir ver las dudas sin resolver del curso' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas sin solución para nombre del curso', 'contenido duda 1', 'contenido duda 2')
      expect(arg1[:text]).to_not include('contenido duda 7', 'contenido duda 8')

    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Usuario debe poder elegir crear duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Escriba a continuación la duda que desea crear relacionada con *nombre del curso*:')
      expect(arg1[:text]).to_not include('contenido duda 1', 'contenido duda 2', 'contenido duda 7', 'contenido duda 8')

    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'No marca como pulsada una opción mientras no se seleccione ninguna' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas sin solución para nombre del curso', 'contenido duda 1')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas sin solución para nombre del curso', 'contenido duda 1')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder dejar cambiar de opción' do
    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas sin solución para nombre del curso', 'contenido duda 1')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva duda' }

    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Escriba a continuación la duda que desea crear relacionada con *nombre del curso*:')
      expect(arg1[:text]).to_not include('contenido duda 1', 'contenido duda 2', 'contenido duda 7', 'contenido duda 8')

    }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Escriba a continuación la duda que desea crear relacionada con *nombre del curso*:')
      expect(arg1[:text]).to_not include('contenido duda 1', 'contenido duda 2', 'contenido duda 7', 'contenido duda 8')

    }

    @accion.recibir_mensaje(@stub_mensaje)

  end

  it 'Debe dejar retroceder al menú anterior' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe dejar retroceder al menú anterior incluso si hay una opción pulsada' do

    double_id_ultimo_mensaje=double('double_aux')
    allow(double_id_ultimo_mensaje).to receive_message_chain(:[], :[])

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Dudas sin solución para nombre del curso', 'contenido duda 1')
    }.and_return(double_id_ultimo_mensaje)

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end


  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db[:dudas].delete
    @db.disconnect

  end
end