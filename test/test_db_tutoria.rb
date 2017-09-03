require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/tutoria'
require_relative 'spec_helper'

describe Tutoria do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:estudiante].insert(id_telegram: 1111)

    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario2.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario2.com', token: '2222', id_moodle: 2222)
    @db[:estudiante].insert(id_telegram: 2222)

    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombreusuario1')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'usuario3@usuario3.com')
    @db[:datos_moodle].insert(email: 'usuario3@usuario3.com', token: '2222', id_moodle: 3333)
    @db[:profesor].insert(id_telegram: 3333)

    @db[:tutoria].insert(id_profesor: 3333, dia_semana_hora: '2020-07-02 18:39:08')

    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 1111, hora_solicitud: '2020-07-02 12:39:08', dia_semana_hora: '2020-07-02 18:39:08')
    @db[:peticion_tutoria].insert(id_profesor: 3333, id_estudiante: 2222, hora_solicitud: '2020-07-02 13:39:08', dia_semana_hora: '2020-07-02 18:39:08')

    @tutoria = Tutoria.new(Profesor.new(3333), '2020-07-02 18:39:08')
    @db.disconnect
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:dudas].delete
    @db[:respuestas].delete
    @db.disconnect
  end

  it 'Devolver las peticiones que tiene' do
    peticiones = @tutoria.peticiones
    peticion1 = Peticion.new(@tutoria, Estudiante.new(1111))
    peticion2 = Peticion.new(@tutoria, Estudiante.new(2222))
    contiene1 = false
    contiene2 = false
    cont = 0
    while cont < peticiones.size
      contiene1 = true if peticiones[cont] == peticion1
      contiene2 = true if peticiones[cont] == peticion2
      cont += 1
    end
    expect(contiene1 && contiene2).to be(true)
    expect(peticiones.size).to be 2
  end

  it 'Devolver el número de peticiones a una tutoría' do
    expect(@tutoria.numero_peticiones).to be 2
  end

  it 'Devolver la posicion de una peticion' do
    expect(@tutoria.posicion_peticion(Peticion.new(@tutoria, Estudiante.new(1111)))).to be 0
    expect(@tutoria.posicion_peticion(Peticion.new(@tutoria, Estudiante.new(2222)))).to be 1
  end

  it 'Devolver las  peticiones ordenadas por su fecha realización' do
    peticiones = @tutoria.peticiones
    peticion_anterior = peticiones[0]
    peticiones.each_with_index do |peticion, i|
      if i != 0
        expect(peticion.hora > peticion_anterior.hora).to be true
        peticion_anterior = peticion
      end
    end
  end
end
