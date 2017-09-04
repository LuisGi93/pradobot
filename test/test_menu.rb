require_relative 'spec_helper'

describe Menu do


  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:curso].delete
    @db[:usuario_telegram].delete
    @db[:curso].insert(id_moodle: 5, nombre_curso: 'curso 5')
    @db[:curso].insert(id_moodle: 7, nombre_curso: 'curso 7')
    @db[:curso].insert(id_moodle: 9, nombre_curso: 'curso 9')

    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:estudiante].insert(id_telegram: 1111)
    @db[:estudiante_curso].insert(id_estudiante: 1111, id_moodle_curso: 5)
    @db[:estudiante_curso].insert(id_estudiante: 1111, id_moodle_curso: 7)


    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:profesor].insert(id_telegram: 2222)
    @db[:profesor_curso].insert(id_profesor: 2222, id_moodle_curso: 7)
    @db[:profesor_curso].insert(id_profesor: 2222, id_moodle_curso: 9)



  end

  before(:each) do
    @stub_bot = double('bot')

    Accion.establecer_bot(@stub_bot)

    allow(@stub_mensaje).to receive_message_chain(:usuario, :id_telegram) { 1111 }
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
    @hereda_de_menu = MenuPrincipalProfesor.new
    @hereda_de_menu.cambiar_curso(@stub_curso)

    allow(@stub_bot).to receive_message_chain(:api, :send_message)
    allow(@stub_bot).to receive_message_chain(:api, :edit_message_text)
    allow(@stub_bot).to receive_message_chain(:api, :answer_callback_query, :[], :[])

  end

  it 'Menús deben comprobar el contenido del mensaje cada vez que reciben uno' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Cambiar de curso ' }

    expect(@stub_mensaje).to receive(:datos_mensaje)

    @hereda_de_menu.recibir_mensaje(@stub_mensaje)
  end

  it 'Los distintos menús de la aplicación deben detectar que se quiere cambiar de curso a partir de los datos del mensaje' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Cambiar de curso ' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:text]).to include('Elija curso:')
    }
    @hereda_de_menu.recibir_mensaje(@stub_mensaje)
  end

  it 'Debe proporcionarse un menú tipo Inline para que el usuario elija curso' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'Cambiar de curso ' }

    expect(@stub_bot).to receive_message_chain(:api, :send_message) { |arg1|
      expect(arg1[:reply_markup]).to be_instance_of(Telegram::Bot::Types::InlineKeyboardMarkup)
      expect(arg1[:text]).to include('Elija curso:')
    }
    @hereda_de_menu.recibir_mensaje(@stub_mensaje)
  end

  it 'El menú debe indicar al usuario que se está producienco el cambio de curso cuando detecta que el usuario ha pulsado un curso en el menú' do
    allow(@stub_mensaje).to receive(:datos_mensaje) { 'cambiando_a_curso_id_curso#7' }
    expect(@stub_bot).to receive_message_chain(:api,:answer_callback_query) { |arg1|
      expect(arg1[:text]).to include('Cambiando de curso..')
    }
    @hereda_de_menu.recibir_mensaje(@stub_mensaje)
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:curso].delete
    @db[:usuario_telegram].delete
  end


end