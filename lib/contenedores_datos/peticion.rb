require_relative 'conexion_bd'

#Contiene los datos de una petición a tutoría
class Peticion < ConexionBD
  attr_reader :tutoria, :estudiante
  attr_accessor :hora, :estado
  def initialize(tutoria, estudiante, hora = nil)
    @tutoria = tutoria
    @estudiante = estudiante
    @hora = hora
  end

  # 
  # Devuelve la hora a la que se realizó la petición 
  #  *Returns* :
  #   - String  
  def hora
    if @hora.nil?
      datos_peticion = @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).select(:hora_solicitud)
      @hora = datos_peticion.to_a[0][:hora_solicitud].strftime('%Y-%m-%d %H:%M:%S')
    end
    @hora
  end

  # 
  # Devuelve el estado de la petición
  #  *Returns* :
  #   - String puede ser aceptada, rechaza, sin responder 
  def estado
    if @estado.nil?
      datos_peticion = @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).select(:estado)
      puts datos_peticion.to_a.to_s
      @estado = datos_peticion.to_a[0][:estado]
    end
    @estado
  end

  # 
  #Cambia el estado de una petición a aceptada
  def aceptar
    @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).update(estado: 'aceptada')
  end

  #Cambia el estado de una petición a denegada 
  def denegar
    @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).update(estado: 'rechazada')
  end

  def <=>(y)
    if hora < y.hora
      -1
    elsif hora == y.hora
      0
    else
      1
    end
  end

  # 
  # Compara si sus datos son iguales a los de otra Peticion
  #  *Returns* :
  #   - True si es verdad, False en caso contrario
  def ==(y)
    @tutoria == y.tutoria && @estudiante == y.estudiante
  end
end
