require "rspec"
require 'sequel'
require_relative '../lib/contenedores_datos/usuario_desconocido'
require_relative '../lib/contenedores_datos/curso'

describe UsuarioDesconocido do
  before(:all) do



    @db=Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @profesor_desconocido =UsuarioDesconocido.new(1111,"pepito grillo")
#    @db[:curso].insert(:id_moodle => 5, :nombre_curso => "curso 5")
#    @db[:curso].insert(:id_moodle => 6, :nombre_curso => "curso 6")
#    @db[:curso].insert(:id_moodle => 7, :nombre_curso => "curso 7")
    @profesor_desconocido.email="email@desconocido.com"
    @profesor_desconocido.nombre_usuario="desconocido"
    @profesor_desconocido.rol="profesor"
    @profesor_desconocido.id_moodle="11111"
    @profesor_desconocido.token="abcd1234"
    @profesor_desconocido.cursos << Curso.new(5, 'curso 5')
    @profesor_desconocido.cursos << Curso.new(6, 'curso 6')

    @estudiante_desconocido =UsuarioDesconocido.new(2222, "nebraska")
    @estudiante_desconocido.email="alumno@desconocido.com"
    @estudiante_desconocido.nombre_usuario="alumno desconocido"
    @estudiante_desconocido.rol="estudiante"
    @estudiante_desconocido.id_moodle="22222"
    @estudiante_desconocido.token="1234abcd"
    @estudiante_desconocido.cursos << Curso.new(5, 'curso 5')
    @estudiante_desconocido.cursos << Curso.new(7, 'curso 7')
    @db.disconnect
  end

  after(:all) do
    @db=Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:tutoria].delete
    @db[:respuestas].delete
    @db.disconnect
  end

  it "Debe poder registrarse en el sistema como profesor junto con los cursos de los que es responsable" do
    expect(@db[:curso].where(:id_moodle => 5, :nombre_curso => 'curso 5').to_a.size).to be 0
    expect(@db[:curso].where(:id_moodle => 6, :nombre_curso => 'curso 6').to_a.size).to be 0
    @profesor_desconocido.rol="profesor"
    @profesor_desconocido.registrarme_en_el_sistema
    expect(@db[:usuario_telegram].where(:id_telegram => 1111, :nombre_usuario => "desconocido").to_a.size).to be 1
    expect(@db[:usuarios_moodle].where(:id_telegram => 1111, :email => "email@desconocido.com").to_a.size).to be 1
    expect(@db[:datos_moodle].where(:email => "email@desconocido.com", :token => "abcd1234", :id_moodle => 11111).to_a.size).to be 1
    expect(@db[:profesor].where(:id_telegram => 1111).to_a.size).to be 1
    expect(@db[:profesor_curso].where(:id_profesor => 1111, :id_moodle_curso => 5).to_a.size).to be 1
    expect(@db[:profesor_curso].where(:id_profesor => 1111, :id_moodle_curso => 6).to_a.size).to be 1
    expect(@db[:curso].where(:id_moodle => 5, :nombre_curso => 'curso 5').to_a.size).to be 1
    expect(@db[:curso].where(:id_moodle => 6, :nombre_curso => 'curso 6').to_a.size).to be 1
  end

  it "Debe poder registrarse en el sistema como estudiante en los cursos en los que es reponsable un profesor dado de alta en el sistema" do
    @estudiante_desconocido.registrarme_en_el_sistema
    expect(@db[:usuario_telegram].where(:id_telegram => 2222, :nombre_usuario => "alumno desconocido").to_a.size).to be 1
    expect(@db[:usuarios_moodle].where(:id_telegram => 2222, :email => "alumno@desconocido.com").to_a.size).to be 1
    expect(@db[:datos_moodle].where(:email => "alumno@desconocido.com", :token => "1234abcd", :id_moodle => 22222).to_a.size).to be 1
    expect(@db[:estudiante].where(:id_telegram => 2222).to_a.size).to be 1
    expect(@db[:estudiante_curso].where(:id_estudiante => 2222, :id_moodle_curso => 5).to_a).to_not be_empty
    expect(@db[:estudiante_curso].where(:id_estudiante => 2222, :id_moodle_curso => 6).to_a).to be_empty
    expect(@db[:estudiante_curso].where(:id_estudiante => 2222, :id_moodle_curso => 7).to_a).to be_empty
  end


  

end
