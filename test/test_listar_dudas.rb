
require 'telegram/bot'
require 'rspec'
require_relative '../lib/contenedores_datos/duda'
require_relative '../lib/actuadores_sobre_mensajes/accion.rb'
require_relative '../lib/actuadores_sobre_mensajes/listar_dudas_pendientes.rb'
require_relative '../lib/actuadores_sobre_mensajes/listar_dudas_resueltas.rb'
require_relative '../lib/actuadores_sobre_mensajes/listar_mis_dudas.rb'
require_relative '../lib/actuadores_sobre_mensajes/listar_dudas.rb'
require_relative '../lib/actuadores_sobre_mensajes/menu_dudas.rb'
describe ListarDudas do
  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    @stub_curso = double('curso')
    allow(@stub_curso).to receive(:nombre) { 'nombre del curso' }
    allow(@stub_curso).to receive(:id_moodle) { 5 }
    allow(@stub_curso).to receive(:obtener_profesor_curso) { @stub_usuario1 }
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
    allow(@stub_usuario2).to receive(:id_telegram) { 21 }
    allow(@stub_usuario3).to receive(:id_telegram) { 34 }
    allow(@stub_usuario1).to receive(:nombre_usuario) { 'usuario1' }
    allow(@stub_usuario2).to receive(:nombre_usuario) { 'usuario2' }
    allow(@stub_usuario3).to receive(:nombre_usuario) { 'usuario3' }

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 21 }
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }
    allow(@stub_mensaje).to receive(:id_chat) { 1234 }
    allow(@stub_mensaje).to receive(:id_mensaje) { 1234 }
    allow(@stub_mensaje).to receive(:id_callback) { 1234 }

    @stub_duda = double('duda2')
    allow(@stub_duda).to receive(:contenido) { 'contenido duda 2' }
    allow(@stub_duda).to receive(:usuario) { @stub_usuario2 }
    stub_respuesta = double('respuesta')
    allow(stub_respuesta).to receive(:contenido) { 'Contenido de la solución de la duda' }
    allow(@stub_duda).to receive(:solucion) { stub_respuesta }
    @array_dudas_curso = []
    @array_dudas_curso << Duda.new('contenido duda 1', @stub_usuario1)
    @array_dudas_curso << @stub_duda
    allow(@stub_curso).to receive(:obtener_dudas_sin_resolver) { @array_dudas_curso }

    allow(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :delete_message)
  end

  it 'Debe poder mostrar dudas sin solución del curso' do
    allow(@stub_mensaje).to receive(:tipo) { '' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    expect(@stub_curso).to receive(:obtener_dudas_sin_resolver) { @array_dudas_curso }
    expect(@stub_bot).to receive_message_chain(:api, :send_message, :[], :[])

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder ver las acciones que se pueden hacer sobre una duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }
    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Duda 1' }

    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
                           expect(arg1.keys).to include(:reply_markup)
                           expect(arg1[:text]).to include('contenido duda 2', 'elegida')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder borrar una duda elegida' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Duda 1' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Borrar duda' }

    expect(@stub_curso).to receive(:eliminar_duda) { |arg1|
                             arg1.contenido == 'contenido duda 2'
                             arg1.usuario.id_telegram == 21
                           }
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
      expect(arg1[:text]).to include('eliminada')
    }
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder ver respuestas a una duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Duda 1' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Ver respuestas' }
    array_respuestas = []
    array_respuestas << Respuesta.new('contenido respuesta 1', @stub_usuario1, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 2', @stub_usuario2, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 3', @stub_usuario3, @stub_duda)
    allow(@stub_duda).to receive(:respuestas) { array_respuestas }

    expect(@stub_duda).to receive(:respuestas)

    @accion.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe poder solicitar elegir solucion a duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Duda 1' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Elegir solución' }
    array_respuestas = []
    array_respuestas << Respuesta.new('contenido respuesta 1', @stub_usuario1, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 2', @stub_usuario2, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 3', @stub_usuario3, @stub_duda)
    allow(@stub_duda).to receive(:respuestas) { array_respuestas }

    expect(@stub_duda).to receive(:respuestas)
    expect(@stub_bot).to receive_message_chain(:api, :edit_message_text) { |arg1|
                           expect(arg1.keys).to include(:reply_markup)
                           expect(arg1[:text]).to include('Elija', 'respuesta', 'contenido respuesta 2')
                         }

    @accion.recibir_mensaje(@stub_mensaje)
  end
  it 'Debe poder asignar una respuesta como solución a una duda' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Sin resolver' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:tipo) { 'callbackquery' }
    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Duda 1' }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Elegir solución' }
    array_respuestas = []
    array_respuestas << Respuesta.new('contenido respuesta 1', @stub_usuario1, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 2', @stub_usuario2, @stub_duda)
    array_respuestas << Respuesta.new('contenido respuesta 3', @stub_usuario3, @stub_duda)
    allow(@stub_duda).to receive(:respuestas) { array_respuestas }

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:datos_mensaje) { '##$$Respuesta 2' }
    allow(@stub_duda).to receive(:insertar_solucion)
    expect(@stub_duda).to receive(:insertar_solucion) { |respuesta|
                            expect(respuesta.contenido).to eq('contenido respuesta 3')
                            expect(respuesta.usuario.id_telegram).to eq(@stub_usuario3.id_telegram)
                            expect(respuesta.duda.contenido).to eq('contenido duda 2')
                            expect(respuesta.duda.usuario.id_telegram).to eq(@stub_usuario2.id_telegram)
                          }

    @accion.recibir_mensaje(@stub_mensaje)
  end
end
