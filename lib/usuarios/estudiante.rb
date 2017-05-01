
require_relative 'usuario'

class Estudiante < Usuario

  attr_reader :id
  def initialize id_estudiante
    @id=id_estudiante
  end



  def obtener_entregas_abiertas
    cursos_mostrar=Array.new
    if @curso['id_moodle'].to_i >=0
      id_curso=@@db[:estudiante_curso].where(:id_moodle_curso => @curso['id_moodle'].to_i).first[:id_moodle_curso]
      puts "El id del curso #{@curso['id_moodle'].to_i}"
      curso_con_entregas=@moodle.obtener_entregas_curso(id_curso)
      unless curso_con_entregas.entregas.empty?
        cursos_mostrar << curso_con_entregas
      end
    else
      cursos_usuario=@@db[:estudiante_curso].where(:id_estudiante => @id_telegram).select(:id_curso).to_a
      cursos_usuario.each{ |id_curso|
        curso_con_entregas=obtener_entregas_curso(id_curso)
        unless curso_con_entregas.entregas.empty?
          cursos_mostrar << curso_con_entregas
        end
      }
    end

    return cursos_mostrar
  end


  def obtener_cursos_estudiante
    consulta_cursos_alumno=@@db[:estudiante_curso].where(:id_estudiante => @id).select(:id_moodle_curso).to_a
    cursos_alumno=Array.new
    consulta_cursos_alumno.each{|curso|
      cursos_alumno << Curso.new( curso[:id_moodle_curso])
    }
    return cursos_alumno
  end



  def obtener_peticiones_tutorias
    peticiones=Array.new
    datos_peticiones=@@db[:peticion_tutoria].where(:id_estudiante => @id).to_a
    puts datos_peticiones.to_s
    #Al alumno se le pide que peticiones a realizado y no ha tutorio porque tutoria representa a una tutoria tal cual
    datos_peticiones.each{|datos_peticion|
      tutoria=Tutoria.new(Profesor.new(datos_peticion[:id_profesor]), datos_peticion[:dia_semana_hora])
        peticiones << Peticion.new(tutoria, Estudiante.new(datos_peticion[:id_estudiante]), datos_peticion[:hora_solicitud])
    }
    return peticiones
  end

  def establecer_db db #Es importante ya que vease el caso de estudiante obtener peticiones es absurdo que para crear un profesor tenga que pasarle una conexcion base datos
    #es mas sencillo sencillamente que esta se pueda establecer "por fuera" y mas intuitivo
    @@db=db
  end

  def token_moodle
    if @token_moodle.nil?
      datos_estudiante=@@db[:estudiante].where(:id_telegram => @id).select(:email).first
      @email=datos_estudiante[:email]
      datos_estudiante=@@db[:estudiante_moodle].where(:email => @email).select(:token).first
      @token_moodle=datos_estudiante[:token]
    end
    return @token_moodle
  end

end