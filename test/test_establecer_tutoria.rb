require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/establecer_tutorias.rb'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_tutorias_profesor.rb'
require 'rspec'
require 'telegram/bot'

describe AccionEstablecerTutorias do
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

    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :delete_message)
  end

  it 'Debe solicitar al profesor que elija el día que desea que tenga lugar la tutoría' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }

    expect(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Debe obtener los datos de día introducido del mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Debe continuar solicitando el día de la semana mientras no se introduza uno válido' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Elija', 'día de la semana', 'tutoría')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe solicitar la hora de la tutoría cuando se introduce un día de la semana válido' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Lunes' }
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Lunes')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe continuar solicitando la hora mientras no se introduzca una hora con formato 00:00, 00:00:00' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Lunes' }

    @accion.recibir_mensaje(@stub_mensaje)
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
                           expect(mensaje[:text]).to include('Hora no válida vuelva a intentarlo')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
                           expect(mensaje[:text]).to include('Hora no válida vuelva a intentarlo')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe aceptar Lunes Martes Jueves Viernes como días válidos' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Lunes' }
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Lunes')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }

    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Martes' }

    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Martes')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Miércoles' }
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Miércoles')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Jueves' }
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Jueves')
    }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Nueva tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensajea).to receive(:datos_mensaje) { 'Viernes' }
    expect(@stub_mensaje).to receive(:datos_mensaje)
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |mensaje|
      expect(mensaje[:text]).to  include('Introduzca', 'hora', 'tutorías', 'Viernes')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end
end
