
require 'rspec'
require_relative '../lib/actuadores_sobre_mensajes/menu_acciones'
require_relative '../lib/actuadores_sobre_mensajes/accion'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_principal_profesor'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_curso'

describe MenuCurso do
  before(:each) do
    stub_bot = double('bot')
    allow(stub_bot).to receive_message_chain(:api, :send_message) { true }
    stub_bd = double('bd')
    allow(stub_bd).to receive_message_chain('[].where') {}

    Accion.establecer_bot(stub_bot)
    Accion.establecer_db(stub_bd)

    @menu_cursos = MenuCurso.new(MenuPrincipalProfesor.new)
    @stub_mensaje = double('mensaje')
    allow(@stub_mensaje).to receive(:obtener_identificador_telegram) { 'identificador aleatorio 1234' }
  end

  it 'No devolver una acción diferente a si misma cuando recibe datos no relacionados con las acciones contenidas en ella' do
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje) { 'datos_aleatorios 5678' }
    result = @menu_cursos.recibir_mensaje(@stub_mensaje)
    expect(result).to be @menu_cursos
  end

  it 'Devolver su acción padre cuando el mensaje recibido indica que quiere ir al menú anterior a ella.' do
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje) { 'Atras' }
    result = @menu_cursos.recibir_mensaje(@stub_mensaje)
    expect(result).to be_instance_of(MenuPrincipalProfesor)
  end
end
