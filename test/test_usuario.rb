require_relative 'spec_helper'

describe Mensaje do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombreusuario1')
    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombreusuario2')

    @db[:profesor].insert(id_telegram: 1111)
    @db[:estudiante].insert(id_telegram: 2222)
  end

  it 'Debe conocer el tipo de usuario al que pertenece su identificador' do
    usuario=Usuario.new(1111, 'nombreusuario1')
    expect(usuario.tipo).to eq('profesor')
    usuario=Usuario.new(2222, 'nombreusuario2')
    expect(usuario.tipo).to eq('estudiante')
    usuario=Usuario.new(3333, 'nombreusur')
    expect(usuario.tipo).to eq('desconocido')
  end

  it 'Su identificador debe corresponde con el que se le pasa al momento de inicializarlo' do
    usuario=Usuario.new(1111, 'nombreusuario1')
    expect(usuario.id_telegram).to eq(1111)
  end

  it 'Su nombre de usuario debe corresponde con el que se le pasa al momento de inicializarlo' do
    usuario=Usuario.new(1111, 'nombreusuario1')
    expect(usuario.nombre_usuario).to eq('nombreusuario1')
  end

  after(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
    @db[:usuario_telegram].delete
    @db.disconnect

  end

end