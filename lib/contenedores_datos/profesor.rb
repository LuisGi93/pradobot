
require_relative 'usuario_registrado'
#Clase que simboliza a un profesor de un curso
class Profesor < UsuarioRegistrado
  def initialize(id_telegram = nil)
    @id_telegram = id_telegram
    @nombre_usuario = nil
  end

  #Añade una nueva petición a una tutoría del profesor
  #  *Returns* :
  #   - True si el estudiante que la ha realizado no ha realizado una petición anterior, False en caso contrario
  def solicitar_tutoria(peticion)
    aceptada = true
    begin
      @@db[:peticion_tutoria].where(id_profesor: @id_telegram, dia_semana_hora: peticion.tutoria.fecha)
                             .insert(id_profesor: @id_telegram, dia_semana_hora: peticion.tutoria.fecha, id_estudiante: peticion.estudiante.id_telegram, hora_solicitud: Time.new.strftime('%Y-%m-%d %H:%M:%S'), estado: 'por aprobar')
    rescue Sequel::ForeignKeyConstraintViolation, Sequel::UniqueConstraintViolation => boom
      aceptada = false
    end
    aceptada
  end

  # Devuelve las tutorías que ha creado el profesor
  #  *Returns* :
  #   - Array de objetos Tutoria
  def obtener_tutorias
    tutorias = []
      datos_tutorias = @@db[:tutoria].where(id_profesor: @id_telegram).to_a
      datos_tutorias.each { |tutoria|
        tutorias << Tutoria.new(self, tutoria[:dia_semana_hora].strftime('%Y-%m-%d %H:%M:%S'))
      }
      tutorias
  end  

  # Crea una nueva tutoría para el profesor 
  def establecer_nueva_tutoria tutoria
    existe_tutoria = @@db[:tutoria].where(id_profesor: @id_telegram, dia_semana_hora: tutoria.fecha)
    if existe_tutoria.empty?
      @@db[:tutoria].insert(id_profesor: @id_telegram, dia_semana_hora: tutoria.fecha)
    end
  end

  def borrar_tutoria(tutoria)
    @@db[:tutoria].where(id_profesor: @id_telegram, dia_semana_hora: tutoria.fecha).delete
  end
end

require_relative 'tutoria'
