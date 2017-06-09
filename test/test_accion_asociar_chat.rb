require "rspec"
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/accion_asociar_chat'
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_chat'

describe AccionAsociarChat do

  before(:each) do
    @stub_bot= double("bot")
    stub_padre = double("padre")
    @stub_db= double("db")

    Accion.establecer_db(@stub_db)
    Accion.establecer_bot(@stub_bot)
    @accion=AccionAsociarChat.new

    allow(@stub_mensaje).to receive(:obtener_identificador_telegram){ 666666 }
    allow(stub_padre).to receive(:cambiar_curso){ true}
    allow(stub_padre).to receive(:curso){ true}

    @accion=MenuChat.new(stub_padre)
    @accion.cambiar_curso("nuevo_cuso", 5)
  end

  it "Cuando se ejecute por primera vez la acción muestra un mensaje indicando que realiza." do
    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'Asociar chat curso'}
    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(:text =>  /Introduzca el nombre del chat al cual quiere asociar .*/))
    @accion.recibir_mensaje(@stub_mensaje)
  end

  it "Si no existe un chat con el nombre introducido por el profesor este debe crearse en la base de datos" do

    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'Asociar chat curso'}
    allow(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(:text =>  /Introduzca el nombre del chat al cual quiere asociar .*/))
    @accion.recibir_mensaje(@stub_mensaje)

    stub_dataset =double("dataset")

    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'nombre_chat'}
    allow(@stub_db).to receive_message_chain(:[], :where){stub_dataset}
    allow(stub_dataset).to receive(:empty?){true}

    expect(@stub_db).to receive_message_chain(:[],:insert)
    expect(@stub_db).to receive_message_chain(:[],:insert)

    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /^Curso.* asociado al chat/))

    @accion.recibir_mensaje(@stub_mensaje)

  end

  it "Si  existe un chat con el nombre introducido por el profesor este debe actualizarse en la base de datos" do

    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'Asociar chat curso'}
    allow(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(:text =>  /Introduzca el nombre del chat al cual quiere asociar .*/))
    @accion.recibir_mensaje(@stub_mensaje)

    stub_dataset =double("dataset")

    allow(@stub_mensaje).to receive(:obtener_datos_mensaje){ 'nombre_chat'}
    allow(@stub_db).to receive_message_chain(:[], :where){stub_dataset}
    allow(stub_dataset).to receive(:empty?){false}

    expect(@stub_db).to receive_message_chain(:[], :where,:update)

    expect(@stub_bot).to receive_message_chain(:api, :send_message).with(hash_including(text: /^Curso.* asociado al chat/))

    @accion.recibir_mensaje(@stub_mensaje)

  end


end