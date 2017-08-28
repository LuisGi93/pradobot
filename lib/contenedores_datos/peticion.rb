require_relative 'conexion_bd'

class Peticion < ConexionBD
  attr_reader :tutoria, :estudiante
  attr_accessor :hora, :estado
  def initialize(tutoria, estudiante, hora = nil)
    @tutoria = tutoria
    @estudiante = estudiante
    @hora = hora
  end

  def hora
    if @hora.nil?
      datos_peticion = @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).select(:hora_solicitud)
      @hora = datos_peticion.to_a[0][:hora_solicitud].strftime('%Y-%m-%d %H:%M:%S')
    end
    @hora
  end

  def estado
    if @estado.nil?
      datos_peticion = @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).select(:estado)
      puts datos_peticion.to_a.to_s
      @estado = datos_peticion.to_a[0][:estado]
    end
    @estado
  end

  def aceptar
    @@db[:peticion_tutoria].where(id_profesor: @tutoria.profesor.id_telegram, dia_semana_hora: @tutoria.fecha, id_estudiante: @estudiante.id_telegram).update(estado: 'aceptada')
  end

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

  def ==(y)
    @tutoria == y.tutoria && @estudiante == y.estudiante
  end
end
