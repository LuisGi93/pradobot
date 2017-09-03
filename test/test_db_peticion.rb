require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/estudiante'
require_relative '../lib/contenedores_datos/duda'
require_relative '../lib/contenedores_datos/respuesta'
require_relative 'spec_helper'

describe Peticion do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario2')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '1111', id_moodle: 2222)
    @db[:estudiante].insert(id_telegram: 2222)

    @db[:usuario_telegram].insert(id_telegram: 4444, nombre_usuario: 'nombreusuario2')
    @db[:usuarios_moodle].insert(id_telegram: 4444, email: 'usuario4@usuario4.com')
    @db[:datos_moodle].insert(email: 'usuario4@usuario4.com', token: '1111', id_moodle: 4444)
    @db[:estudiante].insert(id_telegram: 4444)

    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'usuario3@usuario3.com')
    @db[:datos_moodle].insert(email: 'usuario3@usuario3.com', token: '2222', id_moodle: 3333)
    @db[:profesor].insert(id_telegram: 3333)

    @db[:tutoria].insert(id_profesor: 3333,  dia_semana_hora: '2020-07-02 18:39:08')
    @db[:tutoria].insert(id_profesor: 3333,  dia_semana_hora: '2020-07-05 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 1111, hora_solicitud: '2020-07-01 12:39:08', dia_semana_hora: '2020-07-02 18:39:08', estado: 'por aprobar')
    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 1111, hora_solicitud: '2020-07-01 12:39:08', dia_semana_hora: '2020-07-05 18:39:08', estado: 'por aprobar')
    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 2222, hora_solicitud: '2020-07-01 13:39:08', dia_semana_hora: '2020-07-02 18:39:08', estado: 'por aprobar')
    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 4444, hora_solicitud: '2020-07-01 11:39:08', dia_semana_hora: '2020-07-02 18:39:08', estado: 'por aprobar')
    @db.disconnect

    @peticion = Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(1111))
  end

  after(:all) do
    db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    db[:usuario_telegram].delete
    db[:usuarios_moodle].delete
    db[:dudas].delete
    db[:respuestas].delete
    db.disconnect
  end

  it 'Devolver la hora en la que se realizo' do
    iguales = @peticion.hora == '2020-07-01 12:39:08'

    expect(iguales).to be true
  end

  it 'Devolver el estado en el que se encuentra la petición' do
    iguales = @peticion.estado == 'por aprobar'
    expect(iguales).to be true
  end

  it 'se debe poder aceptar' do
    @peticion = Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(1111))
    @peticion.aceptar
    iguales = @peticion.estado == 'aceptada'
    puts @peticion.estado
    puts 'aceptar'
    expect(iguales).to be true
  end

  it 'se tiene que poder denegar' do
    @peticion = Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(1111))
    @peticion.denegar
    iguales = @peticion.estado == 'rechazada'
    expect(iguales).to be true
  end

  it 'si es igual a otra petición devuelve true' do
    expect(@peticion == Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(1111))).to be true
  end

  it 'si es diferente a otra petición devuelve false' do
    expect(@peticion == Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-05 18:39:08'), Estudiante.new(1111))).to be false
  end

  it 'Debe devoler 1 si su hora de realización es mayor que otra petición, 0 si igual o -1 si menor' do
    expect(@peticion <=> Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(2222))).to be -1
    expect(@peticion <=> Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(1111))).to be 0
    expect(@peticion <=> Peticion.new(Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08'), Estudiante.new(4444))).to be 1
  end
end
