
require_relative 'conexion_bd'

class UsuarioDesconocido < ConexionBD

  attr_accessor  :email, :rol, :cursos, :token, :contrasena, :id_telegram, :id_moodle, :nombre_usuario

  def initialize id_telegram, nombre_usuario
    @id_telegram= id_telegram
    @nombre_usuario= nombre_usuario
    @cursos=Array.new
  end


  def anadir_cursos_moodle( cursos)
      @cursos=cursos
  end

  def registrarme_en_el_sistema
    @@db.from(:usuario_telegram).insert(:id_telegram => @id_telegram, :nombre_usuario => @nombre_usuario )

    if @rol == 'profesor'
      @@db.from(:profesor).insert(:id_telegram => @id_telegram)
      @@db.from(:usuarios_moodle).insert(:id_telegram => @id_telegram, :email =>@email )
      @@db.from(:datos_moodle).insert(:email =>@email, :token => @token, :id_moodle => @id_moodle)
      cursos_ya_existentes=@@db.from(:profesor_curso).select(:id_moodle_curso).to_a
      @cursos.each{
          |curso|
        unless cursos_ya_existentes.include? curso.id_curso
          @@db.from(:curso).insert(:nombre_curso => curso.nombre, :id_moodle => curso.id_curso)
          @@db.from(:profesor_curso).insert(:id_profesor => @id_telegram, :id_moodle_curso => curso.id_curso)
        end
      }
    else
      @@db.from(:estudiante).insert(:id_telegram => @id_telegram)
      @@db.from(:usuarios_moodle).insert(:id_telegram => @id_telegram, :email =>@email )
      @@db.from(:datos_moodle).insert(:email =>@email, :token => @token, :id_moodle => @id_moodle)
      @cursos.each{
          |curso|
        unless @@db.from(:curso).where(:id_moodle => curso.id_curso).to_a.empty?
          @@db.from(:estudiante_curso).insert(:id_estudiante => @id_telegram, :id_moodle_curso => curso.id_curso)
        end
      }
    end
  end



end
