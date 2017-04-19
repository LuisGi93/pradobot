class Usuario
  attr_accessor  :email, :rol, :cursos, :token, :contrasena, :id_telegram, :id_moodle, :nombre_usuario

  def initialize
    @cursos=Array.new
  end

  def anadir_curso id_curso, nombre_curso
    @cursos << {:id_moodle => id_curso, :nombre_curso => nombre_curso }
  end

  def anadir_cursos_moodle( cursos)
    cursos.each{|curso|
      anadir_curso(curso['id'], curso['fullname'])
    }
  end
end