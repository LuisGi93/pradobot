require_relative 'conexion_bd'



class Usuario < ConexionBD
  attr_reader :id
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
      dataset=@@db[:usuario_telegram].where(:id_telegram=> @id).select(:nombre_usuario)
      @nombre_usuario=dataset.first[:nombre_usuario]
    end
    return @nombre_usuario
  end



end

require_relative 'curso'