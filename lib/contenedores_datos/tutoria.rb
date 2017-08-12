require_relative 'conexion_bd'
class Tutoria < ConexionBD
  attr_reader :profesor, :fecha, :peticiones
  def initialize(profesor, fecha)
    @profesor=profesor
    @fecha=fecha
    @peticiones=Array.new
  end

  def posicion_peticion peticion
    peticiones=@@db[:peticion_tutoria].where(:id_profesor => @profesor.id_telegram, :dia_semana_hora => @fecha).order(:hora_solicitud).to_a
    id_estudiante=peticion.estudiante.id_telegram
    contador=0
    while(contador < peticiones.size && peticiones[contador][:id_estudiante] != id_estudiante )
      contador+=1
    end
    return contador
  end

  def numero_peticiones
    numero_peticiones=@@db[:peticion_tutoria].where(:id_profesor => @profesor.id_telegram, :dia_semana_hora => @fecha).count
    return numero_peticiones
  end

  def peticiones
    if @peticiones.empty?
      datos_peticiones=@@db[:peticion_tutoria].where(:id_profesor => @profesor.id_telegram, :dia_semana_hora => @fecha).to_a
      datos_peticiones.each{|datos_peticion|
          @peticiones << Peticion.new(self, Estudiante.new(datos_peticion[:id_estudiante]), datos_peticion[:hora_solicitud])
      }
    end
    return @peticiones
  end

  def == (y)
    return @profesor== y.profesor && @fecha == y.fecha
  end
end

require_relative 'peticion'
require_relative 'profesor'
