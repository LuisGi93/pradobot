
require "rspec"
require_relative '../lib/acciones/menu_acciones'
require_relative '../lib/acciones/accion'
require_relative '../lib/acciones/acciones_profesor/menu_principal_profesor'
require_relative '../lib/acciones/acciones_profesor/menu_curso'

describe AccionEntregasAlumno do

  before(:all)do
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @accion=AccionEntregaAlumno.new(token)

  end

  before(:each) do
    stub_bot= double("bot")
    Accion.establecer_bot(stub_bot)

    stub_moodle= double("moodle")

    @accion=AccionEntregasAlumno.new(id_telegram, stub_entrega)

    @stub_mensaje= double("mensaje")
    allow(@stub_mensaje).to receive(:obtener_identificador_telegram){ id_telegram}
  end

  it "Mostrar un menu con todas las entregas" do
    entrega0={:nombre => "Entrega 0", :fecha => "10-01-2017 21:21:21"}
    entrega1={:nombre => "Entrega 0", :fecha => "10-01-2017 21:21:21"}
    entregas=Array.new
    entregas << entrega0
    entregas << entrega1
    allow(@stub_entrega).to receive(:obtener_entregas){entregas}
    expect(stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(reply_markup: kind_of(Telegram::Bot::Types::InlineKeyboardMarkup)))
    @accion_entrega.ejecutar()
  end#

  it "Obtener informacion de una entrega en concreto" do
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'ver_entrega_0'}
    expect(stub_alumno).to receive(:obtener_descripcion_entrega).with(0)
    expect(stub_bot).to receive_message_chain(:api, :edit_message_text)
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it "Realizar entrega" do
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'realizar_entrega_0'}
    expect(stub_alumno).to receive(:obtener_descripcion_entrega).with(0)
    expect(stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: "Introduzca la entrega a continuación:"))
    @accion.recibir_mensaje(@stub_mensaje)
  end



end