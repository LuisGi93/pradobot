require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/estudiante'

describe Profesor do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombreusuario3')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'usuario3@usuario3.com')
    @db[:datos_moodle].insert(email: 'usuario3@usuario3.com', token: '1111', id_moodle: 3333)
    @db[:estudiante].insert(id_telegram: 3333)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '2222', id_moodle: 2222)
    @db[:profesor].insert(id_telegram: 2222)

    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 2222, dia_semana_hora: '2020-07-05 18:39:08')

    @profesor = Profesor.new(2222)
    @db.disconnect
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:dudas].delete
    @db[:respuestas].delete
    @db.disconnect
  end

  it 'Recibir peticiones a tutoria' do
    peticion1 = Peticion.new(Tutoria.new(@profesor, '2020-07-02 18:39:08'), Estudiante.new(1111))
    @profesor.solicitar_tutoria peticion1
    expect(@db[:peticion_tutoria].where(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08', id_estudiante: 1111).to_a.size).to be 1
    @db[:peticion_tutoria].delete
  end

  it 'Devolver su nombre de usuario' do
    nombre_usuario = @profesor.nombre_usuario
    iguales = nombre_usuario == 'nombreusuario1'
    expect(iguales).to be true
  end

  it 'Devolver un array con sus tutorías' do
    tutorias = @profesor.obtener_tutorias
    expect(tutorias).to be_instance_of(Array)

    expect(tutorias.size).to be 2
    tutoria1 = Tutoria.new(@profesor, '2020-07-02 18:39:08')
    tutoria2 = Tutoria.new(@profesor, '2020-07-05 18:39:08')

    contiene1 = false
    contiene2 = false
    cont = 0
    while cont < tutorias.size
      contiene1 = true if tutorias[cont] == tutoria1
      contiene2 = true if tutorias[cont] == tutoria2
      cont += 1
    end
    expect(contiene1 && contiene2).to be(true)
  end

  it 'Poder crear una nueva tutoria' do
    nueva_tutoria = Tutoria.new(@profesor, '2020-07-02 18:39:08')
    expect(@db[:tutoria].where(id_profesor: 2222, dia_semana_hora: '2020-07-02 18:39:08').to_a.size).to be 1
  end
end
