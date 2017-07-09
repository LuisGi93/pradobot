require 'test/unit'
require 'shoulda'
require 'telegram/bot'
require "rspec/mocks/standalone"
require_relative '../lib/actuadores_sobre_mensajes/acciones_profesor/menu_principal_profesor'

class MenuMenusTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  context "Test de la clase encargada del funcionamiento de un menú de menús utilizando teclado Telegram" do
    setup do
      stub_db= Object.new
      stub_db.stub_chain("[]").and_return(true)
      stub_bot= Object.new
      stub_bot.stub_chain("api.send_message").and_return(true)
      Accion.establecer_bot(stub_bot)
      @menu_principal=MenuPrincipalProfesor.new
      @menu_principal.cambiar_curso("Curso8")
      @menu_cursos=MenuCurso.new(@menu_principal)
    end


    should "Devolver nulo si el contenido del mensaje no identifica a un menú de los contenidos" do
      assert_nil @menu_principal.accion_pulsada('id_aleatoria','werwer234')
    end

    should "Devolver el menú si el contenido del mensaje identifica a un menú entre contenidos" do
      assert_instance_of MenuCurso, @menu_principal.accion_pulsada('id_aleatoria', 'Gestionar curso')
      assert_instance_of MenuChat,@menu_principal.accion_pulsada('id_aleatoria','Chat Telegram')
    end

    should "Devolver el menú correcto en función del contenido del mensaje" do
      assert_instance_of MenuCurso,@menu_principal.obtener_siguiente_accion('id_aleatoria','Gestionar curso')
      assert_instance_of MenuChat,@menu_principal.obtener_siguiente_accion('id_aleatoria','Chat Telegram')
    end

    should "Devolverse a si mismo mientras los datos recibidos no identifiquen a una acción del menu" do
      assert_instance_of MenuPrincipalProfesor, @menu_principal.obtener_siguiente_accion('id_aleatoria', 'datos_aleatorios')
    end

    should "No cambiar de menu mientras los datos recibidos no identifiquen a una acción del menu" do
      assert_instance_of MenuPrincipalProfesor, @menu_principal.obtener_siguiente_accion('id_aleatoria', 'datos_aleatorios')
    end

    should "Devolverse a si mismo si no tiene menú" do
      assert_instance_of MenuPrincipalProfesor,@menu_principal.obtener_siguiente_accion('id_aleatoria','Atras')
    end



    should "Cambiar de curso cuando recibe del chat la cadena que indica que se quiere cambiar de curso" do #todo
     # stub_mensaje= Object.new
      #stub_mensaje.stub('obtener_identificador_telegram'){'id_aleatoria'}
      #stub_mensaje.stub('obtener_datos_mensaje'){'Cambiar curso. Curso actual: Curso3'}
      #@menu_principal.recibir_mensaje(stub_mensaje)
      #assert_equal 'Curso3', @menu_principal.curso
    end


    should "Debe devolver un menu siempre a pesar de los datos que le lleguen" do
      stub_mensaje= Object.new
      stub_mensaje.stub('obtener_identificador_telegram'){'id_aleatoria'}
      stub_mensaje.stub('obtener_datos_mensaje'){'datos_aleatorios'}
      assert_kind_of MenuDeMenus,@menu_principal.recibir_mensaje(stub_mensaje)
    end


    # Called after every test method runs. Can be used to tear
    # down fixture information.

    def teardown

      # Do nothing
    end

    # Fake test
    def test_fail

      fail('Not implemented')
    end

  end
end
