require_relative 'conexion_bd'



class Usuario < ConexionBD
  attr_reader :id_telegram

  def initialize id_telegram=nil
    @id_telegram=id_telegram
    @nombre_usuario=nil
  end

  def obtener_cursos_usuario
    id_cursos_usuario=@@db[:estudiante_curso].where(:id_estudiante => @id_telegram).select(:id_moodle_curso).to_a
    if id_cursos_usuario.empty?
      id_cursos_usuario=@@db[:profesor_curso].where(:id_profesor => @id_telegram).select(:id_moodle_curso).to_a
    end
    cursos=Array.new
    id_cursos_usuario.each{|curso|
      cursos << Curso.new(curso[:id_moodle_curso])
    }
    return cursos
  end

  def nombre_usuario

    if @nombre_usuario.nil?
      dataset=@@db[:usuario_telegram].where(:id_telegram=> @id_telegram).select(:nombre_usuario)
      @nombre_usuario=dataset.first[:nombre_usuario]
    end
    return @nombre_usuario
  end

  def dudas
    mis_dudas=Array.new
    datos_dudas=@@db[:dudas].where(:id_usuario_duda => @id_telegram).to_a
    datos_dudas.each{|datos_duda|
      mis_dudas << Duda.new(datos_duda[:contenido_duda], Usuario.new(datos_duda[:id_usuario_duda]))
    }
    return mis_dudas
  end

  def == (y)
    return @id_telegram == y.id_telegram
  end


end

require_relative 'curso'