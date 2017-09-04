require_relative 'spec_helper'

describe MenuTutorias do

  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombreusuario3')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'usuario3@usuario3.com')
    @db[:datos_moodle].insert(email: 'usuario3@usuario3.com', token: '1111', id_moodle: 3333)
    @db[:estudiante].insert(id_telegram: 3333)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '2222', id_moodle: 2222)
    @db[:profesor].insert(id_telegram: 2222)

    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-05 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 3333, hora_solicitud: '2020-07-02 12:39:08', dia_semana_hora: '2020-07-05 18:39:08', estado: 'por aprobar')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-02 18:39:08', estado: 'aceptada')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-05 18:39:08', estado: 'por aprobar')

    @profesor = Profesor.new(2222)
  end

  before(:each) do
    @stub_bot = double('bot')
    Accion.establecer_bot(@stub_bot)
    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 2222 }
    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }
    @stub_padre = double('accion_padre')
    allow(@stub_padre).to receive(:ejecutar)
    allow(@stub_padre).to receive(:cambiar_curso)
    allow(@stub_padre).to receive(:cambiar_curso_parientes)
    allow(@stub_padre).to receive(:curso) { @stub_curso }
    @accion=MenuTutoriasProfesor.new(@stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :delete_message)


  end


  it 'Debe poder selecciona la opcion Ver información/cola solicitudes' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Gestionar tutorías' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('tutoría', '2020-07-02 18:39:08', '2020-07-05 18:39:08', '1', '2')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Usuario debe poder seleccionar la opción de solicitar tutorias' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }


    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'No marca como pulsada una opción mientras no se seleccione ninguna' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'datos aleatorios' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to_not  include('día de la semana', 'tutoría')
      expect(mensaje[:text]).to_not  include('tutoría', '2020-07-02 18:39:08', '2020-07-05 18:39:08', '1', '2')

    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder dejar cambiar de opción' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Gestionar tutorías' }


    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('tutoría', '2020-07-02 18:39:08', '2020-07-05 18:39:08', '1', '2')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }

    @accion.recibir_mensaje(@stub_mensaje)

  end

  it 'Debe dejar retroceder al menú anterior' do

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Atras' }

    expect(@stub_padre).to receive(:ejecutar)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe dejar retroceder al menú anterior incluso si hay una opción pulsada' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
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