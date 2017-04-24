require_relative 'conexion_bd'

class Tutoria < ConexionBD
  attr_reader :profesor, :fecha, :peticiones
  def initialize(profesor, fecha)
    @profesor=profesor
    @fecha=fecha
    @peticiones=nil
  end

  def posicion_peticion peticion
    peticiones=@@db[:peticion_tutoria].where(:id_profesor => @profesor.id, :dia_semana_hora => @fecha).to_a
    id_estudiante=peticion.estudiante.id
    contador=0
    while(peticiones[contador][:id_estudiante] != id_estudiante && contador < peticiones.size)
      contador+=1
    end
    return contador
  end


end