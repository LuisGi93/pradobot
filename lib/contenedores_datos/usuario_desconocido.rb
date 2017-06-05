
require_relative 'conexion_bd'

class UsuarioDesconocido < ConexionBD

  attr_accessor  :email, :rol, :cursos, :token, :contrasena, :id_telegram, :id_moodle, :nombre_usuario

  def initialize id_telegram=nil
    @id_telegram= id_telegram
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

  def que_tipo_usuario_soy
    usuario= @@db[:usuario_telegram].where(:id_telegram => @id_telegram).first
    tipo_usuario="desconocido"
    if usuario
      es_profesor=@@db[:profesor].where(:id_telegram => @id_telegram).first
      if es_profesor
        tipo_usuario='profesor'
      else
        es_estudiante=@@db[:estudiante].where(:id_telegram => @id_telegram).first
        if es_estudiante
          tipo_usuario='estudiante'
        else
          es_admin=@@db[:admin].where(:id_telegram => @id_telegram).first
          if es_admin
            tipo_usuario='admin'
          end
        end
      end
    end
    return tipo_usuario
  end

  
end