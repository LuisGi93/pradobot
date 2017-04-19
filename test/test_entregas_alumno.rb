
require "rspec"
require_relative "../lib/acciones/acciones_estudiante/accion_mostrar_entregas"
require "telegram/bot"
require_relative "../lib/acciones/acciones_estudiante/menu_entregas"
require_relative "../lib/moodle/curso"
require_relative "../lib/moodle/entrega"

describe AccionMostrarEntregas do
  before(:each) do
    @stub_bot= double("bot")
    stub_db= double("db")
    @stub_moodle= double("moodle")
    @stub_mensaje= double("mensaje")
    stub_padre = double("padre")


    Accion.establecer_bot(@stub_bot)
    Accion.establecer_db(stub_db)

    allow(stub_padre).to receive(:cambiar_curso){ true}
    allow(stub_padre).to receive(:curso){ true}

    allow(@stub_bot).to receive_message_chain(:api, :send_message)

    stub_array=double("array")
    allow(stub_db).to receive_message_chain(:[], :where){stub_array}
    allow(stub_array).to receive_message_chain(:first, :[]){5}
    allow(stub_array).to receive(:to_a){Array.new << 5}

    allow(stub_db).to receive_message_chain(:[], :where, :first, :[] ){6}

    @accion=MenuEntregas.new(stub_padre, @stub_moodle)
    @accion.cambiar_curso("nuevo_cuso", 5)
    allow(@stub_mensaje).to receive(:obtener_identificador_telegram){ 5555}
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'Ver proximas entregas'}
  end

  it "Mostrar un menu con todas las entregas de un curso en concreto" do
    entregas=Array.new

    entregas << Entrega.new("1-1-21", 1, "entrega 1")
    entregas << Entrega.new("2-1-21", 2, "entrega 2")
    entregas << Entrega.new("4-1-21", 4, "entrega 4")
    curso=Curso.new(5, "curso 5")
    curso.establecer_entregas_curso(entregas)

    allow(@stub_moodle).to receive(:obtener_entregas_curso){curso}
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(reply_markup: kind_of(Telegram::Bot::Types::InlineKeyboardMarkup)))
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it "Mostrar mensaje de error si no hay entregas" do
    entregas=Array.new
    curso=Curso.new(5, "curso 5")
    curso.establecer_entregas_curso(entregas)

    allow(@stub_moodle).to receive(:obtener_entregas_curso){curso}
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /No hay ninguna entrega que mostrar/))
    @accion.recibir_mensaje(@stub_mensaje)
  end


  it "Obtener informacion de una entrega en concreto" do

    entregas=Array.new

    entregas << Entrega.new("1-1-21", 1, "entrega 1")
    entregas << Entrega.new("2-1-21", 2, "entrega 2")
    entregas << Entrega.new("4-1-21", 4, "entrega 4")
    curso=Curso.new(5, "curso 5")
    curso.establecer_entregas_curso(entregas)
    allow(@stub_moodle).to receive(:obtener_entregas_curso){curso}

    @accion.recibir_mensaje(@stub_mensaje)

    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'entrega_1_curso5'}
    expect(@stub_moodle).to receive(:obtener_entrega).with(1,5){entregas[0]}
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /\*Nombre:\*/))
    @accion.recibir_mensaje(@stub_mensaje)
  end






end