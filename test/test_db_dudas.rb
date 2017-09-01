require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/estudiante'
require_relative '../lib/contenedores_datos/duda'
require_relative '../lib/contenedores_datos/respuesta'

describe Duda do
  before(:all) do
    db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    db[:usuario_telegram].insert(id_telegram: 111_111, nombre_usuario: 'nombre cualquiera1')

    db[:usuarios_moodle].insert(id_telegram: 111_111, email: 'usuario1@usuario1.com')
    db[:usuario_telegram].insert(id_telegram: 222_222, nombre_usuario: 'nombre cualquiera2')
    db[:usuarios_moodle].insert(id_telegram: 222_222, email: 'usuario2@usuario.2com')
    db[:dudas].insert(id_usuario_duda: 111_111, contenido_duda: 'soy una duda con respuestas')
    db[:dudas].insert(id_usuario_duda: 222_222, contenido_duda: 'soy una duda sin ninguna respuesta')

    db[:respuestas].insert(id_usuario_respuesta: 222_222, contenido_respuesta: 'respuesta numero 1')
    db[:respuestas].insert(id_usuario_respuesta: 222_222, contenido_respuesta: 'respuesta numero 3')
    db[:respuesta_duda].insert(id_usuario_respuesta: 222_222, contenido_respuesta: 'respuesta numero 1', id_usuario_duda: 111_111, contenido_duda: 'soy una duda con respuestas')
    db[:respuesta_duda].insert(id_usuario_respuesta: 222_222, contenido_respuesta: 'respuesta numero 3', id_usuario_duda: 111_111, contenido_duda: 'soy una duda con respuestas')
    db[:respuesta_resuelve_duda].insert(id_usuario_respuesta: 222_222, contenido_respuesta: 'respuesta numero 3', id_usuario_duda: 111_111, contenido_duda: 'soy una duda con respuestas')

    db.disconnect
  end

  after(:all) do
    db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])
    db[:usuario_telegram].delete
    db[:usuarios_moodle].delete
    db[:dudas].delete
    db[:respuestas].delete
    db.disconnect
  end

  it 'Devolver true si el contenido de dos dudas y los usuarios asociados a ellas son los mismos' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    duda1 = Duda.new('contenido de la duda', usuario_duda)
    duda2 = Duda.new('contenido de la duda', usuario_duda)
    iguales = duda1 == duda2
    expect(iguales).to be true
  end

  it 'Devolver false si las dos dudas son de usuarios difentes o tienen contenido diferente' do
    usuario_duda = UsuarioRegistrado.new(1111)
    duda1 = Duda.new('contenido de la duda1', usuario_duda)
    duda2 = Duda.new('contenido de la duda2', usuario_duda)
    iguales = duda1 == duda2
    expect(iguales).to be false
    usuario_duda = UsuarioRegistrado.new(2222)
    duda2 = Duda.new('contenido de la duda1', usuario_duda)
    iguales = duda1 == duda2
    expect(iguales).to be false
  end

  it 'Devolver un array vacio si no ha tenido ninguna respuesta' do
    usuario_duda = UsuarioRegistrado.new(222_222)
    duda = Duda.new('soy una duda sin ninguna respuesta', usuario_duda)
    respuestas = duda.respuestas
    expect(respuestas).to be_empty
  end

  it 'Devolver un array de Respuesta si ha tenido alguna respuesta' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    respuestas = duda.respuestas
    expect(respuestas.empty?).to be false
    expect(respuestas).to be_instance_of(Array)
    respuestas.each do |respuesta|
      expect(respuesta).to be_instance_of(Respuesta)
    end
  end

  it 'Las respuestas a la duda tienen que ser las que estan asociadas a ella en al base de datos ' do
    array_respuestas = []
    usuario_duda = UsuarioRegistrado.new(111_111)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    usuario_respuesta = UsuarioRegistrado.new(222_222)
    respuesta1 = Respuesta.new('respuesta numero 1', usuario_respuesta, duda)
    respuesta2 = Respuesta.new('respuesta numero 3', usuario_respuesta, duda)
    respuestas = duda.respuestas

    contiene1 = false
    contiene2 = false
    cont = 0
    while cont < respuestas.size
      contiene1 = true if respuestas[cont] == respuesta1
      contiene2 = true if respuestas[cont] == respuesta2
      cont += 1
    end
    expect(contiene1 && contiene2).to be(true)
    expect(respuestas.size).to be 2
  end

  it 'Debe devolver una respuesta como solucion a una duda' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    respuesta = duda.solucion
    expect(respuesta).to be_instance_of Respuesta
  end

  it 'Debe devolver nil en caso de que no tenga solucion' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    duda = Duda.new('soy una duda sin ninguna respuestas', usuario_duda)
    respuesta = duda.solucion
    expect(respuesta).to be_nil
  end

  it 'Si una duda tiene solucion su contenido tiene que ser el de la respuesta almacenada en la base de datos' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    usuario_respuesta_solucion = UsuarioRegistrado.new(222_222)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    solucion_duda = Respuesta.new('respuesta numero 3', usuario_respuesta_solucion, duda)
    expect(solucion_duda == duda.solucion).to be true
  end

  it 'Si una duda tiene solucion su contenido tiene que ser el de la respuesta almacenada en la base de datos' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    usuario_respuesta_solucion = UsuarioRegistrado.new(222_222)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    solucion_duda = Respuesta.new('respuesta numero 3', usuario_respuesta_solucion, duda)
    expect(solucion_duda == duda.solucion).to be true
  end

  it 'Una duda puede aceptar nuevas respuestas' do
    usuario_duda = UsuarioRegistrado.new(111_111)
    usuario_respuesta_solucion = UsuarioRegistrado.new(222_222)
    duda = Duda.new('soy una duda con respuestas', usuario_duda)
    nueva_respuesta = Respuesta.new('esto es una nueva respuesta', usuario_respuesta_solucion, duda)
    duda.nueva_respuesta(nueva_respuesta)

    respuestas = duda.respuestas

    contiene_respuesta = false
    cont = 0
    while cont < respuestas.size && contiene_respuesta == false
      contiene_respuesta = true if respuestas[cont] == nueva_respuesta
      cont += 1
    end
    expect(contiene_respuesta).to be true
  end

  it 'Una duda sin solucion puede aceptar una respuesta como solucion' do
    usuario_duda = UsuarioRegistrado.new(222_222)
    usuario_respuesta_solucion = UsuarioRegistrado.new(111_111)
    duda = Duda.new('soy una duda sin ninguna respuesta', usuario_duda)
    solucion_duda = Respuesta.new('esto es una nueva respuesta que ni existe en la base de datos', usuario_respuesta_solucion, duda)
    duda.nueva_respuesta(solucion_duda)
    duda.insertar_solucion(solucion_duda)
    expect(duda.solucion == solucion_duda).to be true
  end
end
