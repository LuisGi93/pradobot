require 'test/unit'
require 'shoulda'
require 'sequel'

class BaseDeDatosTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  context "Test informacion relativa usuario" do
     setup do
      @db = Sequel.connect(ENV['URL_DATABASE'], :user=>ENV['USER_DATABASE'], :password=>ENV['PASSW_DATABASE'])
      @tabla_usuarios_telegram=@db.from(:usuarios_telegram)
      @tabla_usuarios_moodle=@db.from(:usuarios_moodle)
      @db.from(:usuarios_telegram).where(:id_telegram => 0101).delete
      @db.from(:usuarios_moodle).where(:id_moodle => 1010101).delete




      @db=Sequel.connect(ENV['URL_DATABASE']+'/bd_prueba')

      @db.from(:usuarios).insert(:tipo_usuario => 'profesor_bot', :email => 'email@email.com')
      @db.from(:usuarios).insert(:tipo_usuario => 'alumno_bot',  :email => 'email2@email2.com')

      @db.from(:usuarios_telegram).insert(:id_telegram => 11111, :nombre_usuario => 'usuario1111', :email => 'email@email.com')
      @db.from(:usuarios_telegram).insert(:id_telegram => 22222, :nombre_usuario => 'usuario2222', :email => 'email2@email2.com')
    end


    should "Es posible insertar y obtener datos usuarios de telegram correctamente" do
      @tabla_usuarios_telegram.insert(:id_telegram => 0101, :email => '0@0.com',
                                         :fecha_alta => '2012-08-03 15:00:01' )
      assert_equal @db.from(:usuarios_telegram).where(:id_telegram => 0101).all[0][:nombre_usuario], 'pulgarcito'
    end

    should "Es posible insertar y obtener datos usuarios de moodle correctamente" do
      @tabla_usuarios_moodle.insert(:nombre => "Perez", :apellidos => "Galdos", :email => "perez-galdos@cartagena.com", :tipo_usuario => "profesor",
                                      :token_moodle => '123abc', :fecha_alta => '2012-08-03 15:00:01' , :id_moodle => '1010101')
      assert_equal @db.from(:usuarios_moodle).where(:id_moodle => 1010101).all[0][:email], 'perez-galdos@cartagena.com'
    end
    # Called after every test method runs. Can be used to tear
    # down fixture information.

    def teardown
      @db.from(:usuarios_telegram).where(:id_telegram => 0101).delete
      @db.from(:usuarios_moodle).where(:id_moodle => 1010101).delete
      @db.disconnect
      # Do nothing
    end

    # Fake test
    def test_fail

      fail('Not implemented')
    end

  end
end
