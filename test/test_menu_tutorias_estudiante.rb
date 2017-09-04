require_relative 'spec_helper'

describe MenuTutorias do

  before(:all){
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])

    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '2222', id_moodle: 2222)
    @db[:profesor].insert(id_telegram: 2222)

    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-05 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 12:39:08', dia_semana_hora: '2020-07-02 18:39:08')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-03 13:39:08', dia_semana_hora: '2020-07-05 18:39:08')

  }

  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 1111 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    @stub_curso = double('curso')



    @stub_tutoria1 = double('tutoria1')
    @stub_tutoria2 = double('tutoria2')
    allow(@stub_tutoria1).to receive(:fecha){'2017-11-05'}
    allow(@stub_tutoria2).to receive(:fecha){'2017-11-06'}
    allow(@stub_tutoria1).to receive(:numero_peticiones){5}
    allow(@stub_tutoria2).to receive(:numero_peticiones){8}
    array_tutorias = Array.new

    array_tutorias << @stub_tutoria1
    array_tutorias << @stub_tutoria2

    @stub_profesor = double('profesor')

    allow(@stub_profesor).to receive(:id_telegram){2222}

    allow(@stub_profesor).to receive(:nombre_usuario){'nombre profesor'}
    allow(@stub_profesor).to receive(:obtener_tutorias){array_tutorias}
    allow(@stub_profesor).to receive(:solicitar_tutoria){TRUE}
    allow(@stub_profesor).to receive(:nombre_usuario){'nombre profesor'}

    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_profesor }

    @stub_padre = double('accion_padre')
    allow(@stub_padre).to receive(:ejecutar)
    allow(@stub_padre).to receive(:cambiar_curso)
    allow(@stub_padre).to receive(:cambiar_curso_parientes)
    allow(@stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuTutorias.new(@stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])

  end

  it 'No marca como pulsada una opción mientras no se seleccione ninguna' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Usuario debe poder seleccionar la opción de solicitar tutorias' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver solicitudes realizadas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Ha realizado las siguientes peticiones para las tutorias de','nombre profesor', '2020-07-02 12:39:08', '2020-07-03 13:39:08', 'Hora realizacion:', 'Lugar en la cola', '0', '1')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Usuario debe poder seleccionar la opción de ver solicitudes realizadas' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Una vez pulsada una opción del menú esta debe ser la que reciba los mensajes mientras el usuario no indique otra opción del menú' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '1234 aleatorio' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe dejar retroceder al menú anterior' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe dejar retroceder al menú anterior incluso si hay una opción pulsada' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db.disconnect
  end
end