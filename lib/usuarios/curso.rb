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
      @profesor=Profesor.new(id_profesor)
    end
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
    chat=@@db[:chat_telegram].where(:nombre_chat => nombre_chat_telegram)

    if chat.empty?
      @@db[:chat_telegram].insert(:nombre_chat => nombre_chat_telegram.titleize)
      @@db[:chat_curso].insert(:nombre_chat_telegram => nombre_chat_telegram.titleize, :id_moodle_curso => @id_curso)
    else
      @@db[:chat_curso].where(:id_moodle_curso => @id_curso ).update(:nombre_chat_telegram => nombre_chat_telegram.titleize)
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

  def nueva_duda duda, estudiante
    @@db[:dudas].insert(:id_moodle_curso => @id_curso, :id_estudiante => estudiante.id, :contenido => duda.contenido)
  end

  def obtener_dudas
    datos_dudas=@@db[:dudas].where(:id_moodle_curso => @id_curso).to_a
    dudas=Array.new
    datos_dudas.each{|dato_duda|
      dudas << Duda.new(dato_duda[:contenido])
    }

    return dudas
  end



end

require_relative 'profesor'
require_relative 'duda'