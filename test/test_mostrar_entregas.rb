require_relative 'spec_helper'

describe AccionMostrarEntregas do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    @stub_curso = double('curso')
    @stub_entrega1= double('entrega1')
    @stub_entrega2=double('entrega2')
    fecha1=DateTime.new(2011,3,3).strftime('%d-%m-%Y %H:%M:%S')
    fecha2=DateTime.new(2055,3,3).strftime('%d-%m-%Y %H:%M:%S')

    allow(@stub_entrega1).to receive(:fecha_fin){fecha1}
    allow(@stub_entrega2).to receive(:fecha_fin){fecha2}
    allow(@stub_entrega1).to receive(:nombre){'entrega1'}
    allow(@stub_entrega2).to receive(:nombre){'entrega1'}
    allow(@stub_entrega1).to receive(:descripcion){'descripcion entrega1'}
    allow(@stub_entrega2).to receive(:descripcion){'descripcion entrega2'}

    array_entregas=Array.new
    array_entregas << @stub_entrega1
    array_entregas << @stub_entrega2
    allow(@stub_curso).to receive(:entregas){array_entregas}

    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuEntregas.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])

  end

  it 'Enviar un nuevo mensaje cuando recibe su primer mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver calificaciones' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Obtiene las proximas entregas del curso activo para el usuario' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_curso).to receive(:entregas)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Comprueba las fechas de las entregas antes de mostrarlas' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_entrega1).to receive(:fecha_fin)
    expect(@stub_entrega2).to receive(:fecha_fin)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Envia un mensaje al usuario sobre las próximas entregas del curso' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('próximas entregas', 'nombre del curso')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Mostrar las fechas de las próximas entregas en el mensaje enviado al usuario' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('03-03-2055')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'No debe mostrar las fechas de las  entregas del curso ya pasadas' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to_not include('03-03-2011')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Envia un mensaje con un teclado para que elija una entrega' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1.keys).to include(:reply_markup,:text)
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end



  it 'Cuando selecciona una entrega muestra la descripción de esta' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Entrega0' }

    expect(@stub_entrega2).to receive(:descripcion)
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to include('descripcion entrega2')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Si no es el primer mensaje que recibe debe editar siempre el anterior mensaje que envió' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Entrega0' }


    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    @accion.recibir_mensaje(@stub_mensaje)
  end


  it 'Permitir al usuario volver al menú Inline de entregas tras haber visto la descripción de las entregas' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Entrega0' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Volver' }
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to include('próximas entregas', 'nombre del curso')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

end