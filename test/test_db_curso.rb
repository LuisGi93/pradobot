require 'rspec'
require 'sequel'
require_relative '../lib/contenedores_datos/curso'

describe Curso do
  before(:all) do
    @db = Sequel.connect(ENV['URL_DATABASE_PRUEBA'])

    @db[:usuario_telegram].insert(id_telegram: 1111, nombre_usuario: 'nombre cualquiera1')
    @db[:usuarios_moodle].insert(id_telegram: 1111, email: 'usuario1@usuario1.com')
    @db[:datos_moodle].insert(email: 'usuario1@usuario1.com', token: '1111', id_moodle: 1111)
    @db[:usuario_telegram].insert(id_telegram: 2222, nombre_usuario: 'nombre cualquiera2')
    @db[:usuarios_moodle].insert(id_telegram: 2222, email: 'usuario2@usuario.com')
    @db[:datos_moodle].insert(email: 'usuario2@usuario.com', token: '2222', id_moodle: 2222)
    @db[:dudas].insert(id_usuario_duda: 1111, contenido_duda: 'soy una duda resuelta asociada al curso')
    @db[:dudas].insert(id_usuario_duda: 2222, contenido_duda: 'soy una duda no asociada al curso')
    @db[:dudas].insert(id_usuario_duda: 2222, contenido_duda: 'soy una duda no resuelta asociada al curso')

    @db[:curso].insert(id_moodle: 5, nombre_curso: 'curso test')
    @db[:usuario_telegram].insert(id_telegram: 3333, nombre_usuario: 'nombre profesor curso')
    @db[:usuarios_moodle].insert(id_telegram: 3333, email: 'profesor1@profesor1.com')
    @db[:profesor].insert(id_telegram: 3333)
    @db[:profesor_curso].insert(id_profesor: 3333, id_moodle_curso: '5')

    @db[:dudas_resueltas].insert(id_usuario_duda: 1111, contenido_duda: 'soy una duda resuelta asociada al curso')
    @db[:dudas_resueltas].insert(id_usuario_duda: 2222, contenido_duda: 'soy una duda no asociada al curso')
    @db[:dudas_curso].insert(id_usuario_duda: 1111, contenido_duda: 'soy una duda resuelta asociada al curso', id_moodle_curso: 5)
    @db[:dudas_curso].insert(id_usuario_duda: 2222, contenido_duda: 'soy una duda no resuelta asociada al curso', id_moodle_curso: 5)

    @db[:respuestas].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda resuelta asociada al curso')
    @db[:respuestas].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda no asociada al curso')
    @db[:respuesta_duda].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda resuelta asociada al curso', id_usuario_duda: 1111, contenido_duda: 'soy una duda resuelta asociada al curso')
    @db[:respuesta_duda].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda no asociada al curso', id_usuario_duda: 2222, contenido_duda: 'soy una duda no asociada al curso')
    @db[:respuesta_resuelve_duda].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda resuelta asociada al curso', id_usuario_duda: 1111, contenido_duda: 'soy una duda resuelta asociada al curso')
    @db[:respuesta_resuelve_duda].insert(id_usuario_respuesta: 2222, contenido_respuesta: 'respuesta duda no asociada al curso', id_usuario_duda: 2222, contenido_duda: 'soy una duda no asociada al curso')
    @curso = Curso.new(5)
  end

  after(:all) do
    @db[:usuario_telegram].delete
    @db[:usuarios_moodle].delete
    @db[:dudas].delete
    @db[:curso].delete
    @db[:profesor].delete
    @db[:respuestas].delete

    @db.disconnect
  end

  it 'Devolver su nombre' do
    nombre_curso = @curso.nombre
    verdad = nombre_curso == 'curso test'
    expect(verdad).to be true
  end

  it 'Devolver el profesor que tiene asociado' do
    profesor_curso = Profesor.new(3333)
    iguales = profesor_curso == @curso.obtener_profesor_curso
    expect(iguales).to be true
  end

  it 'Debe poderse asociar nuevas dudas al curso' do
    usuario = Estudiante.new(2222)
    nueva_duda = Duda.new('nueva duda curso', usuario)
    @curso.nueva_duda(nueva_duda)
    dudas = @db[:dudas].where(id_usuario_duda: 2222, contenido_duda: 'nueva duda curso').to_a
    expect(dudas.size).to be 1
    dudas = @db[:dudas_curso].where(id_usuario_duda: 2222, contenido_duda: 'nueva duda curso', id_moodle_curso: 5).to_a
    expect(dudas.size).to be 1
    @db[:dudas].where(id_usuario_duda: 2222, contenido_duda: 'nueva duda curso').delete
  end

  it 'Devolver dudas no resueltas asociados a el' do
    dudas_sin_resolver = @curso.obtener_dudas_sin_resolver
    expect(dudas_sin_resolver).to be_instance_of(Array)
    expect(dudas_sin_resolver.size).to be 1
    iguales = dudas_sin_resolver[0] == Duda.new('soy una duda no resuelta asociada al curso', Estudiante.new(2222))
    expect(iguales).to be true
  end

  it 'Devolver dudas resueltas asociados a el' do
    dudas_resueltas = @curso.obtener_dudas_resueltas
    expect(dudas_resueltas).to be_instance_of(Array)
    expect(dudas_resueltas.size).to be 1
    iguales = dudas_resueltas[0] == Duda.new('soy una duda resuelta asociada al curso', Estudiante.new(1111))
    expect(iguales).to be true
  end

  it 'Devolver dudas asociados a el' do
    dudas = @curso.dudas
    expect(dudas).to be_instance_of(Array)
    expect(dudas.size).to be 2
    duda1 = Duda.new('soy una duda no resuelta asociada al curso', Estudiante.new(2222))
    duda2 = Duda.new('soy una duda resuelta asociada al curso', Estudiante.new(1111))
    contiene1 = false
    contiene2 = false
    cont = 0
    puts dudas.to_s
    while cont < dudas.size
      contiene1 = true if dudas[cont] == duda1
      contiene2 = true if dudas[cont] == duda2
      cont += 1
    end
    puts contiene1
    puts contiene2
    expect(contiene1 && contiene2).to be(true)
  end

  it 'Deben poder eliminar dudas asociadas a el' do
    duda1 = Duda.new('soy una duda no resuelta asociada al curso', Estudiante.new(2222))
    @curso.eliminar_duda(duda1)
    dudas_curso = @curso.dudas
    contiene1 = false
    cont = 0
    while cont < dudas_curso.size
      contiene1 = true if dudas_curso[cont] == duda1
      cont += 1
    end
    expect(contiene1).to be false

    dudas_curso = @curso.dudas
    expect(dudas_curso.size).to be 1
    iguales = dudas_curso[0] == Duda.new('soy una duda resuelta asociada al curso', Estudiante.new(1111))
    expect(iguales).to be true
  end

  it 'Debe poder asociarse un chat con el curso' do
    expect(@db[:chat_curso].where(id_moodle_curso: 5).to_a.size).to eq 0
    @curso.asociar_chat('Nombre Chat')
    puts @db[:chat_curso].where(nombre_chat_telegram: 'Nombre Chat').to_a.to_s
    expect(@db[:chat_curso].where(nombre_chat_telegram: 'Nombre Chat').to_a.size).to eq 1
    expect(@db[:chat_curso].where(id_moodle_curso: 5).to_a[0][:nombre_chat_telegram]).to eq('Nombre Chat')
  end

  it 'Debe poder actualizar el nombre del chat asociado al curso' do
    expect(@db[:chat_curso].where(id_moodle_curso: 5).to_a[0][:nombre_chat_telegram]).not_to eq('Otro Chat')
    @curso.asociar_chat('Otro Chat')
    expect(@db[:chat_curso].where(id_moodle_curso: 5).to_a[0][:nombre_chat_telegram]).to eq 'Otro Chat'
  end
end
