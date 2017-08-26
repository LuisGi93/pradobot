require 'net/http'
require 'open-uri'
require 'json'



class Moodle

  #attr_writer :user_token
  #attr_accessor :user_token
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
   # puts uri.query
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

  def obtener_entregas_curso curso
#Daria la fecha incorrecta si el servidor de moodle y el local tienen una hora diferentes
    datos_curso=api('mod_assign_get_assignments',"courseids[0]" => curso.id_curso)
    #puts curso.id_curso
    #puts datos_curso.to_s
    id_curso=datos_curso['courses'][0]['id']
    nombre_curso=datos_curso['courses'][0]['fullname']
    entregas=datos_curso['courses'][0]['assignments']

    aux_entregas=Array.new
    entregas.each{
      |entrega|
      fecha_convertida=Time.at(entrega['duedate'].to_i).to_datetime
       aux_entregas << Entrega.new( entrega['id'], fecha_convertida, entrega['name'])
      if entrega['intro']
        aux_entregas.last.descripcion=entrega['intro']
      end
    }
    curso.establecer_entregas_curso(aux_entregas)

    return curso

  end

  def obtener_cursos_usuario id_moodle_usuario
        cursos_usuario=Array.new
        params={'userid' => id_moodle_usuario}
        datos_cursos_usuario=api('core_enrol_get_users_courses', params )
        datos_cursos_usuario.each{
            |datos_curso|
            cursos_usuario << Curso.new(datos_curso['id'], datos_curso['fullname'])
        }
    return cursos_usuario
  end

  def obtener_identificador_moodle email
    params={'field' => 'email', 'values[0]'  => email}
    usuario=api('core_user_get_users_by_field ', params)

#puts usuario.to_s
    if usuario.size > 0
      id_usuario_moodle=usuario[0]['id'] #presupongo que el email de moodle es único
    end

    return id_usuario_moodle
  end


  def obtener_entrega entrega, curso
    curso=obtener_entregas_curso(curso)
    index=0
    entregas_curso=curso.entregas
    tamanio_vector=entregas_curso.size
    while(index < tamanio_vector )
      if(entregas_curso[index].id == entrega.id)
        entrega=entregas_curso[index]
        index=tamanio_vector
      end
      index+=1
    end
    return entrega

  end


end

require_relative 'contenedores_datos/curso'
require_relative '../lib/contenedores_datos/entrega'
