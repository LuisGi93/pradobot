require_relative 'profesor'
require_relative 'conexion_bd'

class Curso < ConexionBD

  def initialize  id_curso
    @id_curso=id_curso
    @profesor=nil
  end

  def obtener_profesor_curso
    if @profesor.nil?
      consulta_db=@@db[:profesor_curso].where(:id_moodle_curso => @id_curso).select(:id_profesor)
      id_profesor=consulta_db.first[:id_profesor]
      @profesor=Profesor.new(id_profesor)
      @profesor.establecer_db(@@db)
    end
    return @profesor
  end

end