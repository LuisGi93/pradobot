require_relative 'spec_helper'

describe MenuEntregas do


  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)


    @stub_curso = double('curso')
    @stub_entrega1= double('entrega1')
    @stub_entrega2=double('entrega2')
    fecha1=DateTime.new(2011,3,3).strftime('%d-%m-%Y %H:%M:%S')
    fecha2=DateTime.new(2055,3,3).strftime('%d-%m-%Y %H:%M:%S')
    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 1111 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }



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

  it 'Usuario debe poder seleccionar la opción de mostrar información entregas' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }


      expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
        expect(arg1[:text]).to include('próximas entregas', 'nombre del curso')
      }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Una vez pulsada una opción del menú esta debe ser la que reciba los mensajes mientras el usuario no indique otra opción del menú' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Ver próximas entregas' }


    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('próximas entregas', 'nombre del curso')
    }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { 'cualquier cosa' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('próximas entregas', 'nombre del curso')
    }

    @accion.recibir_mensaje(@stub_mensaje)
  end

end