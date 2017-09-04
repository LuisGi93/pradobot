require_relative 'spec_helper'

describe VerInformacionTutorias do
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

    @profesor = Profesor.new(2222)
  end
  before(:each) do
    @stub_bot = double('bot')
    Accion.establecer_bot(@stub_bot)
    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 21 }
    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }
    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuTutoriasProfesor.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 2222 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Gestionar tutorías' }

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :delete_message)

    @db[:tutoria].delete
    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-05 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 3333, hora_solicitud: '2020-07-02 12:39:08', dia_semana_hora: '2020-07-05 18:39:08', estado: 'por aprobar')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-02 18:39:08', estado: 'aceptada')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-05 18:39:08', estado: 'por aprobar')
  end


  it 'Si el profesor que le manda el mensaje no tiene ninguna tutoría mandar mensaje error' do
    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 342_342 }
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
                           expect(mensaje[:text]).to include('tutoría', 'ninguna')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Debe poderse elegir una tutoría entre las mostradas' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria0' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje.keys).to include(:reply_markup)
                           expect(mensaje[:text]).to include('elegida', '2020-07-02 18:39:08')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Mostrar un mensaje de confirmación si elige borrar la tutoría elegida' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria0' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Borrar tutoría' }
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje.keys).to include(:reply_markup)
                           expect(mensaje[:text]).to include('seguro', '2020-07-02 18:39:08', 'eliminar')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Borrar una tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria0' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Borrar tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Si' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje[:text]).to include('borrada', '2020-07-02 18:39:08')
                         }
    tutorias = Profesor.new(2222).obtener_tutorias
    borrada = true
    tutorias.each do |tutoria|
      borrada = false if tutoria.fecha == '2020-07-02 18:39:08'
    end
    expect(borrada).to eq(false)
    @accion.recibir_mensaje(@stub_mensaje)

    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08')
  end

  it 'Volver a mostrar tutorias si se elige  que no se quiere borrar tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria0' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Borrar tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$No' }
    expect(@stub_mensaje).to receive(:datos_mensaje)

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje[:text]).to include('tutoría', '2020-07-02 18:39:08', '2020-07-05 18:39:08', '1', '2')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Mostrar cola de estudiantes a una tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria0' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Cola alumnos' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje[:text]).to include('Cola asistencia tutoria', 'nombreusuario1')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Mostrar mensaje de error si no hay peticiones aprobadas para una cola' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria1' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Cola alumnos' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje[:text]).to include('No', 'aprobado', 'ninguna petición')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Mostrar peticiones pendientes de ser aceptadas tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria1' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Peticiones pendientes de aceptar' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |mensaje|
                           expect(mensaje[:text]).to include('nombreusuario1', 'Seleccione la petición')
                         }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Denegar petición a una tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria1' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Peticiones pendientes de aceptar' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Peticion 0' }

    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Denegar' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
                           expect(mensaje[:text]).to  eql('Petición rechazada')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Aprobar petición a una tutoría' do
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$tutoria1' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Peticiones pendientes de aceptar' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Peticion 0' }

    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Aceptar' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
                           expect(mensaje[:text]).to  eql('Petición aceptada')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
  end
end
