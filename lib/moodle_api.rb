require 'net/http'
require 'open-uri'
require 'json'


require_relative '../lib/moodle/entrega'
require_relative '../lib/moodle/usuario'
require_relative 'moodle/curso'

class Moodle

  attr_writer :user_token
  attr_accessor :user_token
  def initialize(user_token)
    @user_token = user_token
    @moodle_url="http://" + ENV['MOODLE_HOST'] + "/webservice/rest/server.php"
  end



  def api (function, params=nil)
    uri = URI(@moodle_url)
    if params
      arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}.merge(params)
    else
      arguments= { :wstoken  => @user_token , :moodlewsrestformat => 'json', :wsfunction  => function}
    end
    uri.query = URI.encode_www_form(arguments)
    page = Net::HTTP.get(uri)
    JSON.parse(page)
  end

  def self.obtener_token (username, password, service)
    uri = URI("http://" + ENV['MOODLE_HOST'] + "/login/token.php")
    arguments= { :username  => username , :password => password, :service  => service}
    uri.query = URI.encode_www_form(arguments)
    page = Net::HTTP.get(uri)
    JSON.parse(page)
  end

  def obtener_entregas_curso id_curso
#Daria la fecha incorrecta si el servidor de moodle y el local tienen una hora diferentes
    puts id_curso
    datos_curso=api('mod_assign_get_assignments',"courseids[0]" => id_curso)
    puts datos_curso.to_s
    id_curso=datos_curso['courses'][0]['id']
    nombre_curso=datos_curso['courses'][0]['fullname']
    entregas=datos_curso['courses'][0]['assignments']

    curso=Curso.new(id_curso, nombre_curso)
    aux_entregas=Array.new
    entregas.each{
      |entrega|
      fecha_convertida=Time.at(entrega['duedate'].to_i).to_datetime
       aux_entregas << Entrega.new(fecha_convertida, entrega['id'], entrega['name'])
      if entrega['intro']
        aux_entregas.last.descripcion=entrega['intro']
      end
    }
    curso.establecer_entregas_curso(aux_entregas)

    return curso

  end

  def obtener_cursos_usuario id_moodle_usuario
        params={'userid' => id_moodle_usuario}
        cursos_usuario=api('core_enrol_get_users_courses', params )
    return cursos_usuario
  end

  def obtener_identificador_moodle email
    params={'field' => 'email', 'values[0]'  => email}
    usuario=api('core_user_get_users_by_field ', params)

    if usuario.size > 0
      id_usuario_moodle=usuario[0]['id'] #presupongo que el email de moodle es único
    end

    return id_usuario_moodle
  end


  def obtener_entrega id_entrega, id_curso
    curso=obtener_entregas_curso(id_curso)
    entrega=nil
    index=0
    entregas_curso=curso.entregas
    tamanio_vector=entregas_curso.size
    while(entrega.nil? && index < tamanio_vector )
      if(entregas_curso[index].id == id_entrega)
        entrega=entregas_curso[index]
        index=tamanio_vector
      end
      index+=1
    end
    return entrega

  end


end

