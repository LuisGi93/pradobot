require_relative 'conexion_bd'

class Peticion < ConexionBD
  attr_reader :tutoria, :estudiante
  attr_accessor :hora, :estado
  def initialize tutoria, estudiante, hora=nil
    @tutoria=tutoria
    @estudiante=estudiante
    @hora=hora
  end


  def hora
    if @hora.nil?
      datos_peticion=@@db[:peticion_tutoria].where(:id_profesor => @tutoria.profesor.id, :dia_semana_hora => @tutoria.fecha, :id_estudiante=>@estudiante.id).select(:hora_solicitud)
      @hora=datos_peticion[:hora_solicitud]
    end
    return @hora
  end

  def estado
    if @estado.nil?
      datos_peticion=@@db[:peticion_tutoria].where(:id_profesor => @tutoria.profesor.id, :dia_semana_hora => @tutoria.fecha, :id_estudiante=>@estudiante.id).select(:estado)
      puts datos_peticion.to_a[0][:estado].to_s
      @estado=datos_peticion.to_a[0][:estado]
    end
    return @estado
  end

  def aceptar
      @@db[:peticion_tutoria].where(:id_profesor => @tutoria.profesor.id, :dia_semana_hora => @tutoria.fecha, :id_estudiante=>@estudiante.id).update(:estado => "aceptada")
  end


  def denegar
    @@db[:peticion_tutoria].where(:id_profesor => @tutoria.profesor.id, :dia_semana_hora => @tutoria.fecha, :id_estudiante=>@estudiante.id).update(:estado => "rechazada")
  end

  def <=>(y)
    return hora < y.hora
  end

end