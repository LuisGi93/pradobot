require_relative 'conexion_bd'
require 'active_support/inflector'
require_relative '../moodle_api'

class Curso < ConexionBD
  attr_reader :id_curso, :nombre, :entregas

  @@moodle=Moodle.new(ENV['TOKEN_BOT_MOODLE'])

  def initialize  id_curso, nombre_curso=nil
    @id_curso=id_curso.to_i
    @nombre=nombre_curso
    @profesor=nil
    @entregas=nil
  end

  def obtener_profesor_curso
    if @profesor.nil?
      consulta_db=@@db[:profesor_curso].where(:id_moodle_curso => @id_curso).select(:id_profesor)
      id_profesor=consulta_db.first[:id_profesor]
      puts "El puneitero id del profesor es #{id_profesor}"
      @profesor=Profesor.new(id_profesor)
    end
    puts "El puneitero id del profesor es #{@profesor.id_telegram}"

    return @profesor
  end

  def nombre
    if @nombre.nil?
      dataset=@@db[:curso].where(:id_moodle=> @id_curso).select(:nombre_curso)
      @nombre=dataset.first[:nombre_curso]
    end
    return @nombre
  end



  def establecer_entregas_curso entregas
    @entregas=entregas
  end

  def asociar_chat nombre_chat_telegram

    chat=@@db[:chat_curso].where(:id_moodle_curso => @id_curso)
    if chat.empty?
      @@db[:chat_telegram].insert(:nombre_chat => nombre_chat_telegram.titleize)
      @@db[:chat_curso].insert(:nombre_chat_telegram => nombre_chat_telegram.titleize, :id_moodle_curso => @id_curso)
    else
      @@db[:chat_telegram].where(:nombre_chat => chat.first[:nombre_chat_telegram]).update(:nombre_chat => nombre_chat_telegram.titleize)
    end
  end



  def entregas
    #Se refreca cada vez que se consultan las entregas consultando moodle para evitar almacenar para siempre jamas las entregas que se consultaron por primera vez
      @entregas= Array.new
      puts @id_curso
      datos_curso=@@moodle.api('mod_assign_get_assignments',"courseids[0]" => @id_curso)
      puts datos_curso.to_s
      entregas=datos_curso['courses'][0]['assignments']

      entregas.each{
          |entrega|
        fecha_convertida=Time.at(entrega['duedate'].to_i).to_datetime
        fecha_convertida=Time.at(entrega['duedate'].to_i).strftime("%Y-%m-%d %H:%M:%S")
        @entregas << Entrega.new( entrega['id'], fecha_convertida, entrega['name'])
        if entrega['intro']
          @entregas.last.descripcion=entrega['intro']
        end
      }

    return @entregas

  end

  def nueva_duda duda
    @@db[:dudas].insert(:id_usuario_duda => duda.usuario.id_telegram, :contenido_duda => duda.contenido)
    @@db[:dudas_curso].insert(:id_usuario_duda => duda.usuario.id_telegram, :id_moodle_curso => @id_curso, :contenido_duda => duda.contenido)
  end

  def obtener_dudas_sin_resolver
      dudas_sin_resolver_curso = Array.new
      datos_dudas_curso=@@db[:dudas_curso].where(:id_moodle_curso => @id_curso).select(:id_usuario_duda, :contenido_duda).except(@@db[:dudas_resueltas]).to_a
      datos_dudas_curso.each{ |datos_duda|
        dudas_sin_resolver_curso << Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))

      }

      return dudas_sin_resolver_curso
  end

  def obtener_dudas_resueltas
    dudas_curso=@@db[:dudas_curso].where(:id_moodle_curso => @id_curso).select(:id_usuario_duda, :contenido_duda)
    dudas_resueltas=@@db[:dudas_resueltas]
    datos_dudas_resueltas_curso=dudas_curso.where(:contenido_duda=>dudas_resueltas.select(:contenido_duda),:id_usuario_duda=>dudas_resueltas.select(:id_usuario_duda) ).to_a
    dudas_resueltas_curso= Array.new
    datos_dudas_resueltas_curso.each{ |datos_duda|
      dudas_resueltas_curso<< Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))
    }

    return dudas_resueltas_curso
  end


  def dudas
    dudas_curso = Array.new
    datos_dudas_curso=@@db[:dudas_curso].where(:id_moodle_curso => @id_curso).select(:id_usuario_duda, :contenido_duda).to_a
    datos_dudas_curso.each{ |datos_duda|
      dudas_curso << Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))

    }

    return dudas_curso
  end

    def eliminar_duda duda
      @@db[:dudas].where(:id_usuario_duda => duda.usuario.id_telegram, :contenido_duda => duda.contenido).delete
    end






end

require_relative 'profesor'
require_relative 'estudiante'
require_relative 'duda'
