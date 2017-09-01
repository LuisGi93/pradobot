require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/estudiante'

describe Estudiante do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '2222', id_moodle: 2222)
    @db[:profesor].insert(id_telegram: 2222)

    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'usuario3@usuario3.com')
    @db[:datos_moodle].insert(email: 'usuario3@usuario3.com', token: '2222', id_moodle: 3333)
    @db[:profesor].insert(id_telegram: 3333)

    @db[:tutoria].insert(id_profesor: 2222,  dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 2222,  dia_semana_hora: '2020-07-05 19:39:08')
    @db[:tutoria].insert(id_profesor: 3333, dia_semana_hora: '2020-07-07 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 12:39:08', dia_semana_hora: '2020-07-02 18:39:08')
    @db[:peticion_tutoria].insert(id_profesor: 2222, id_estudiante: 1111, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-05 19:39:08')
    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 1111, hora_solicitud: '2020-07-02 14:39:08', dia_semana_hora: '2020-07-07 18:39:08')

    @estudiante = Estudiante.new(1111)
    @db.disconnect
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:tutoria].delete
    @db[:respuestas].delete
    @db.disconnect
  end

  it 'Devolver sus peticiones de tutoria' do
    peticiones = @estudiante.obtener_peticiones_tutorias
    expect(peticiones).to be_instance_of(Array)
    expect(peticiones.size).to be 3

    profesor1 = Profesor.new(2222)
    peticion1 = Peticion.new(Tutoria.new(profesor1, '2020-07-02 18:39:08'), @estudiante, '2020-07-02 12:39:08')
    peticion2 = Peticion.new(Tutoria.new(profesor1, '2020-07-05 19:39:08'), @estudiante, '2020-07-02 13:39:08')
    peticion3 = Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-07 18:39:08'), @estudiante, '2020-07-02 14:39:08')

    contiene1 = false
    contiene2 = false
    contiene3 = false

    cont = 0
    while cont < peticiones.size
      contiene1 = true if peticiones[cont] == peticion1
      contiene2 = true if peticiones[cont] == peticion2
      contiene3 = true if peticiones[cont] == peticion3
      cont += 1
    end

    expect(contiene1 && contiene2 && contiene3).to be(true)
  end

  it 'Devolver su identificador de telegram' do
    expect(@estudiante.id_telegram).to be 1111
  end
end
