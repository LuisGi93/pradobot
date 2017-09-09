require 'json'
require 'typhoeus'

class Moodle
  def initialize(user_token)
    @user_token = user_token
    @moodle_url = 'https://' + ENV['MOODLE_HOST'] + '/webservice/rest/server.php'
  end 

  def api(function, params = nil)
    if params
      request = Typhoeus::Request.new(
        @moodle_url,
      params: { :wstoken => @user_token, moodlewsrestformat: 'json', :wsfunction => function }.merge(params),
      ssl_verifypeer: false,
      ssl_verifyhost: 0
)
    else
      request = Typhoeus::Request.new(
        @moodle_url,
      params: { :wstoken => @user_token, moodlewsrestformat: 'json', :wsfunction => function },
      ssl_verifypeer: false,
      ssl_verifyhost: 0
)
   end
    salida = request.run

    JSON.parse(salida.body)
  end

  def self.obtener_token(_username, _password, _service)

    request = Typhoeus::Request.new(
      'http://' + ENV['MOODLE_HOST'] + '/login/token.php',
     params: { :username => _username,:password => _password, service: _service },
     ssl_verifypeer: false,
     ssl_verifyhost: 0
)
    salida = request.run
    puts salida.body
    JSON.parse(salida.body)
  end

  def obtener_entregas_curso(curso)
    # Daria la fecha incorrecta si el servidor de moodle y el local tienen una hora diferentes
    datos_curso = api('mod_assign_get_assignments', 'courseids[0]' => curso.id_curso)
    id_curso = datos_curso['courses'][0]['id']
    nombre_curso = datos_curso['courses'][0]['fullname']
    entregas = datos_curso['courses'][0]['assignments']

    aux_entregas = []
    entregas.each { |entrega|
      fecha_convertida = Time.at(entrega['duedate'].to_i).to_datetime
      aux_entregas << Entrega.new(entrega['id'], fecha_convertida, entrega['name'])
      if entrega['intro']
        aux_entregas.last.descripcion = entrega['intro']
      end
    }
    curso.establecer_entregas_curso(aux_entregas)

    curso
  end

  def obtener_cursos_usuario(id_moodle_usuario)
    cursos_usuario = []
        params = { 'userid' => id_moodle_usuario }
        datos_cursos_usuario = api('core_enrol_get_users_courses', params)
        datos_cursos_usuario.each { |datos_curso|
          cursos_usuario << Curso.new(datos_curso['id'], datos_curso['fullname'])
        }
        cursos_usuario
  end

  def obtener_identificador_moodle(email)
    params = { 'field' => 'email', 'values[0]' => email }
    usuario = api('core_user_get_users_by_field ', params)

    if !usuario.empty?
      id_usuario_moodle = usuario[0]['id'] end

    id_usuario_moodle
  end
  def obtener_entrega(entrega, curso)
    curso = obtener_entregas_curso(curso)
    index = 0
    entregas_curso = curso.entregas
    tamanio_vector = entregas_curso.size
    while (index < tamanio_vector)
      if (entregas_curso[index].id == entrega.id)
        entrega = entregas_curso[index]
        index = tamanio_vector
      end
      index += 1
    end
    entrega
  end

end

require_relative 'contenedores_datos/curso'
require_relative '../lib/contenedores_datos/entrega'
