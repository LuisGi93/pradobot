
require_relative 'usuario_registrado'
require 'time'
#Simboliza un estudiante de un curso
class Estudiante < UsuarioRegistrado
  def initialize(id_estudiante)
    @id_telegram = id_estudiante
  end  

  def inicializar_moodle
    email = @@db[:usuarios_moodle].where(id_telegram: @id_telegram).select(:email).first[:email]
    token = @@db[:datos_moodle].where(email: email).select(:token).first[:token]
    @moodle = Moodle.new(token)
  end
  # Obtiene los cursos en los cuales está registrado un estudiante 
  #
  # * *Returns* :
  #   - Array con objetos Curso 
  def obtener_cursos_estudiante
    consulta_cursos_alumno = @@db[:estudiante_curso].where(id_estudiante: @id_telegram).select(:id_moodle_curso).to_a
    cursos_alumno = []
    consulta_cursos_alumno.each { |curso|
      cursos_alumno << Curso.new(curso[:id_moodle_curso])
    }
    cursos_alumno
  end  

  # Devuelve las peticiones que ha relizado un estudiante a tutorías
  #
  # * *Returns* :
  #   - Array con objetos Peticion 
  def obtener_peticiones_tutorias
    peticiones = []
    datos_peticiones = @@db[:peticion_tutoria].where(id_estudiante: @id_telegram).to_a
    datos_peticiones.each { |datos_peticion|
      tutoria = Tutoria.new(Profesor.new(datos_peticion[:id_profesor]), datos_peticion[:dia_semana_hora].strftime('%Y-%m-%d %H:%M:%S'))
      peticiones << Peticion.new(tutoria, Estudiante.new(datos_peticion[:id_estudiante]), datos_peticion[:hora_solicitud].strftime('%Y-%m-%d %H:%M:%S'))
    }
    puts peticiones
    peticiones
  end  

  # 
  # Obtiene las entregas visibles por el en Moodle
  #
  #   # * *Args*    :
  #   - +curso+ -> curso en el cual se consultan las entregas 
  #  *Returns* :
  #   - Array con objetos Entrega
  def obtener_entregas_realizadas(curso)
    if @moodle.nil?
      inicializar_moodle
    end
    entregas_curso = @moodle.obtener_entregas_curso(curso)
    entregas_curso
  end

  # 
  # Obtiene la calificación que tiene en una entrega
  #
  #   # * *Args*    :
  #   - +entrega+ -> entrega a la cual se consulta su nota 
  #  *Returns* :
  #   - String con la nota de la entrega
  def consultar_nota_entrega(entrega)
    if @moodle.nil?
      inicializar_moodle
    end
    estado_entrega = @moodle.api('mod_assign_get_submission_status', 'assignid' => entrega.id) # el que sabe y puede consultar que nota tiene es el alumno

    if estado_entrega['feedback'] && estado_entrega['feedback']['grade']
      return estado_entrega['feedback']['grade']['grade']
    else
      return 'Sin calificar'
    end
  end

end
