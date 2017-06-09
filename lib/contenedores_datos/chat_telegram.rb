require_relative 'conexion_bd'

class ChatTelegram < ConexionBD
  attr_reader :id_chat, :nombre
  def initialize  id_chat, nombre=nil
    @id_chat=id_chat
    @nombre=nombre
  end


  def registrado?
    cursos=@@db[:chat_curso].where(:nombre_chat_telegram => @nombre).to_a
    if cursos.empty?
      return false
    else
      return true
    end
  end



  def establecer_entregas_curso entregas
    @entregas=entregas
  end

  def dar_de_alta
    @@db[:chat_telegram].where(:nombre_chat => @nombre).update(:id_chat => @id_chat)
  end

  def obtener_curso_asociado
    datos_cursos=@@db[:chat_curso].where(:nombre_chat_telegram => @nombre).select(:id_moodle_curso).first
    unless datos_cursos.empty?
      id_curso=datos_cursos[:id_moodle_curso]
      curso=Curso.new(id_curso)
      return curso
    end

  end


end

require_relative 'curso'