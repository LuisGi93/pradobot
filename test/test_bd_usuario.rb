require "rspec"
require 'sequel'
require_relative '../lib/contenedores_datos/usuario'


describe Usuario do
  before(:all) do
    @db=Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].insert(:id_telegram => 1111, :nombre_usuario => "nombreusuario1")
    @db[:usuarios_moodle].insert(:id_telegram => 1111, :email => "usuario1@usuario1.com")
    @db[:datos_moodle].insert(:email => "usuario1@usuario1.com", :token => "1111", :id_moodle => 1111)
    @db[:curso].insert(:id_moodle => 5, :nombre_curso => "curso test")
    @db[:curso].insert(:id_moodle => 6, :nombre_curso => "curso test2")

    @db[:estudiante].insert(:id_telegram => 1111)
    @db[:estudiante_curso].insert(:id_estudiante => 1111, :id_moodle_curso => 5)
    @db[:estudiante_curso].insert(:id_estudiante => 1111, :id_moodle_curso => 6)

    @db[:dudas].insert(:id_usuario_duda => 1111, :contenido_duda =>  "soy una duda resuelta")
    @db[:dudas].insert(:id_usuario_duda => 1111, :contenido_duda =>  "soy una duda no resuelta")
    @db[:dudas_resueltas].insert(:id_usuario_duda => 1111, :contenido_duda =>  "soy una duda resuelta")
    @usuario=Usuario.new(1111)
    @db.disconnect
  end

  after(:all) do
    @db=Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:dudas].delete
    @db[:respuestas].delete
    @db.disconnect
  end


  it "Devolver su identificador de telegram" do
    expect(@usuario.id_telegram).to be 1111
  end

  it "Devolver su nombre de usuario" do
    nombre_usuario=@usuario.nombre_usuario
    iguales=nombre_usuario == "nombreusuario1"
    expect(iguales).to be true
  end

  it "Devolver las dudas que ha creado" do
    dudas=@usuario.dudas
    expect(dudas).to be_instance_of(Array)

    expect(dudas.size).to be 2
    duda1=Duda.new( "soy una duda resuelta",Estudiante.new(1111))
    duda2=Duda.new("soy una duda no resuelta",Estudiante.new(1111))
    contiene1=false
    contiene2=false
    cont=0
    while(cont < dudas.size) do
      if(dudas[cont]==duda1)
        contiene1=true
      end
      if(dudas[cont]==duda2)
        contiene2=true
      end
      cont+=1
    end
    expect(contiene1 && contiene2).to be(true)
  end


  it "Devolver true si dos usuarios son iguales" do
    iguales=@usuario == Usuario.new(1111)
    expect(iguales).to be true
  end

  it "Devolver false si dos usuarios son diferentes" do
    iguales=@usuario == Usuario.new(2222)
    expect(iguales).to be false
  end

end