
require_relative 'conexion_bd'

class UsuarioDesconocido < ConexionBD

  attr_accessor  :email, :rol, :cursos, :token, :contrasena, :id_telegram, :id_moodle, :nombre_usuario

  def initialize id_telegram, nombre_usuario
    @id_telegram= id_telegram
    @nombre_usuario= nombre_usuario
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

  def registrarme_en_el_sistema
    @@db.from(:usuario_telegram).insert(:id_telegram => @id_telegram, :nombre_usuario => @nombre_usuario )

    if @rol == 'profesor'
      @@db.from(:profesor).insert(:id_telegram => @id_telegram)
      @@db.from(:usuarios_moodle).insert(:id_telegram => @id_telegram, :email =>@email )
      @@db.from(:datos_moodle).insert(:email =>@email, :token => @token, :id_moodle => @id_moodle)
      cursos_ya_existentes=@@db.from(:profesor_curso).where(:id_profesor => @id_telegram).select(:id_moodle_curso).to_a
      id_cursos=cursos_ya_existentes
      @cursos.each{
          |curso|
        puts curso
        unless id_cursos.include? curso[:id_moodle]
          @@db.from(:curso).insert(:nombre_curso => curso[:nombre_curso], :id_moodle => curso[:id_moodle])
          @@db.from(:profesor_curso).insert(:id_profesor => @id_telegram, :id_moodle_curso => curso[:id_moodle])
        end
      }
    else
      @@db.from(:estudiante).insert(:id_telegram => @id_telegram)
      @@db.from(:usuarios_moodle).insert(:id_telegram => @id_telegram, :email =>@email )
      @@db.from(:datos_moodle).insert(:email =>@email, :token => @token, :id_moodle => @id_moodle)
      @cursos.each{
          |curso|
        unless @@db.from(:curso).where(:id_moodle => curso[:id_moodle]).to_a.empty?
          @@db.from(:estudiante_curso).insert(:id_estudiante => @id_telegram, :id_moodle_curso => curso[:id_moodle])
        end
      }
    end
  end



end
