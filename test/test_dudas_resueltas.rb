require_relative 'spec_helper'

describe ListarDudasResueltas do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 66 }

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    stub_padre = double('accion_padre')
    allow(stub_padre).to receive(:cambiar_curso)
    allow(stub_padre).to receive(:cambiar_curso_parientes)
    allow(stub_padre).to receive(:curso) { @stub_curso }
    @accion = MenuDudas.new(stub_padre)
    @accion.cambiar_curso(@stub_curso)

    @stub_usuario1 = double('usuario1')
    @stub_usuario2 = double('usuario2')
    @stub_usuario3 = double('usuario3')

    allow(@stub_usuario1).to receive(:id_telegram) { 12 }
    allow(@stub_usuario1).to receive(:id_telegram) { 12 }
    allow(@stub_usuario2).to receive(:id_telegram) { 34 }
    allow(@stub_usuario1).to receive(:nombre_usuario) { 'usuario1' }
    allow(@stub_usuario2).to receive(:nombre_usuario) { 'usuario2' }
    allow(@stub_usuario3).to receive(:nombre_usuario) { 'usuario3' }
  end

  it 'Debe poder mostrar dudas resueltas curso' do
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Resueltas' }

    array_dudas_curso = []
    array_dudas_curso << Duda.new('contenido duda 1', @stub_usuario1)
    array_dudas_curso << Duda.new('contenido duda 2', @stub_usuario2)
    array_dudas_curso << Duda.new('contenido duda 3', @stub_usuario3)

    expect(@stub_curso).to receive(:obtener_dudas_resueltas) { array_dudas_curso }
    expect(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder ver las acciones que se pueden hacer sobre una duda resuelta' do
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Resueltas' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    array_dudas_curso = []

    array_dudas_curso << Duda.new('contenido duda 1', @stub_usuario1)
    array_dudas_curso << Duda.new('contenido duda 2', @stub_usuario2)
    array_dudas_curso << Duda.new('contenido duda 3', @stub_usuario3)
    allow(@stub_curso).to receive(:obtener_dudas_resueltas) { array_dudas_curso }
    allow(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$duda_1' }

    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
                           arg1.keys.should include(:reply_markup)
                           expect(arg1[:text]).to include('contenido duda 2', 'elegida')
                         }
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'En las acciones sobre una duda resuelta debe tenerse en cuenta si el usuario es el creador de la duda o el profesor del curso' do
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Resueltas' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    array_dudas_curso = []
    stub_duda = double('duda2')
    allow(stub_duda).to receive(:contenido) { 'contenido duda 2' }
    allow(stub_duda).to receive(:usuario) { @stub_usuario2 }
    array_dudas_curso << Duda.new('contenido duda 1', @stub_usuario1)
    stub_respuesta = double('respuesta')
    allow(stub_respuesta).to receive(:contenido) { 'Contenido de la solución de la duda' }
    allow(stub_duda).to receive(:solucion) { stub_respuesta }
    array_dudas_curso << stub_duda
    allow(@stub_curso).to receive(:obtener_dudas_resueltas) { array_dudas_curso }
    allow(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$duda_1' }
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    expect(stub_duda).to receive(:usuario) { @stub_usuario2 }
    expect(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }

    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Debe poderse ver la solución de una duda resuelta' do
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Resueltas' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query) { 1234 }

    array_dudas_curso = []
    stub_duda = double('duda2')
    allow(stub_duda).to receive(:contenido) { 'contenido duda 2' }
    allow(stub_duda).to receive(:usuario) { @stub_usuario2 }
    array_dudas_curso << Duda.new('contenido duda 1', @stub_usuario1)
    stub_respuesta = double('respuesta')
    allow(stub_respuesta).to receive(:contenido) { 'Contenido de la solución de la duda' }
    allow(stub_duda).to receive(:solucion) { stub_respuesta }
    array_dudas_curso << stub_duda
    array_dudas_curso << Duda.new('contenido duda 3', @stub_usuario3)
    allow(@stub_curso).to receive(:obtener_dudas_resueltas) { array_dudas_curso }
    allow(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$duda_1' }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Solución duda' }
    stub_respuesta = double('respuesta')
    allow(stub_respuesta).to receive(:contenido) { 'Contenido de la solución de la duda' }
    allow(stub_duda).to receive(:solucion) { stub_respuesta }

    expect(stub_duda).to receive(:solucion)
    expect(stub_respuesta).to receive(:contenido)
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to include('Contenido de la solución de la duda', 'contenido duda 2')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end
end
