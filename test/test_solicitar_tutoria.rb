require_relative 'spec_helper'

describe SolicitarTutoria do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    @stub_curso = double('curso')

    @stub_profesor = double('profesor')
    @stub_tutoria1 = double('tutoria1')
    @stub_tutoria2 = double('tutoria2')
    allow(@stub_tutoria1).to receive(:fecha){'2017-11-05'}
    allow(@stub_tutoria2).to receive(:fecha){'2017-11-06'}
    allow(@stub_tutoria1).to receive(:numero_peticiones){5}
    allow(@stub_tutoria2).to receive(:numero_peticiones){8}
    array_tutorias = Array.new

    array_tutorias << @stub_tutoria1
    array_tutorias << @stub_tutoria2

    allow(@stub_profesor).to receive(:obtener_tutorias){array_tutorias}
    allow(@stub_profesor).to receive(:solicitar_tutoria){TRUE}
    allow(@stub_profesor).to receive(:nombre_usuario){'nombre profesor'}




    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_profesor }

    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuTutorias.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])

  end

  it 'Enviar un nuevo mensaje cuando recibe su primer mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Tras recibir su primer mensaje debe enviar un mensaje sobre las tutorías del profesor del curso' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Tras recibir su primer mensaje debe proporcionar menú para que elija la tutoría que quiere' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:reply_markup]).to be_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup)
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Obtiene las tutorias a mostrar del profesor del curso activo' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }

    expect(@stub_curso).to receive(:obtener_profesor_curso)
    expect(@stub_profesor).to receive(:obtener_tutorias)

    @accion.recibir_mensaje(@stub_mensaje)
  end



  it 'Si selecciona una tutoría debe enviarse la petición de asistencia al profesor' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    expect(@stub_profesor).to receive(:solicitar_tutoria)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Si selecciona una tutoría se tiene que editar el texto del último mensaje enviado y no enviar uno nuevo ' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    allow(@stub_profesor).to receive(:solicitar_tutoria){TRUE}
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'La tutoria sobre la que el alumno solicita debe corresponder con la que ha seleccionado' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    expect(@stub_profesor).to receive(:solicitar_tutoria){ |peticion|
        expect(peticion.tutoria.fecha).to eq('2017-11-05')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'La petición tiene que haber sido realizada por el estudiante' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    expect(@stub_profesor).to receive(:solicitar_tutoria){ |peticion|
      expect(peticion.estudiante.id_telegram).to eq(66)
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe mandarse un mensaje al estudiante si la petición es aceptada' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    allow(@stub_profesor).to receive(:solicitar_tutoria){TRUE}
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to  eq('Solicitud para la tutoria 2017-11-05 registrada.')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe mandarse un mensaje al estudiante si la petición es rechazada' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }

    allow(@stub_profesor).to receive(:solicitar_tutoria){FALSE}
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to  eq('La tutoria elegida no está disponible, compruebe si ya ha solicitado para dicha sesión sino vuelva a intentarlo')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Mientras no selecciona una tutoría se le sigue solicitando que lo haga' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'cualquier cosa' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Tras la realización de la petición debe proporcionarsele un menú con la opción de volver a mostar el menú de tutorías ' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Realizar petición tutoría' }
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Tutoria0' }
    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_profesor).to receive(:solicitar_tutoria){TRUE}
    @accion.recibir_mensaje(@stub_mensaje)
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Volver' }
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to include('Seleccione la tutoría', 'nombre profesor','Fecha tutoría', '2017-11-05', '2017-11-06')
      expect(arg1[:reply_markup]).to be_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup)
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

end