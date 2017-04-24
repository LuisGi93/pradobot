require_relative 'peticion'
require_relative 'conexion_bd'

class Profesor < ConexionBD
  attr_reader :id
  def initialize id_telegram=nil
    @id=id_telegram
    @nombre_usuario=nil
  end

  def solicitar_tutoria peticion
    
    aceptada=true
    begin
      @@db[:peticion_tutoria].where(:id_profesor => @id, :dia_semana_hora => peticion.tutoria.fecha)
        .insert(:id_profesor => @id, :dia_semana_hora => peticion.tutoria.fecha, :id_estudiante => peticion.estudiante.id, :hora_solicitud => peticion.hora)
    rescue  Sequel::ForeignKeyConstraintViolation, Sequel::UniqueConstraintViolation => boom
      aceptada=false

    end
    return aceptada
  end

  def obtener_datos_tutorias
    
    tutorias=@@db[:tutoria].where(:id_profesor => @id).to_a
    tutorias.each{ |tutoria|
      tutoria[:numero_peticiones]=@@db[:peticion_tutoria].where(:id_profesor => @id, :dia_semana_hora => tutoria[:dia_semana_hora]).count
      puts tutoria[:numero_peticiones]
    }
    return tutorias
  end

  def obtener_tutorias
      
      tutorias=@@db[:tutoria].where(:id_profesor => @id).to_a
    return tutorias
  end

  def obtener_posicion_peticion fecha_tutoria, estudiante
    
    peticiones=@@db[:peticion_tutoria].where(:id_profesor => @id, :dia_semana_hora => fecha_tutoria).to_a
    id_estudiante=estudiante.id
    contador=0
    while(peticiones[contador][:id_estudiante] != id_estudiante && contador < peticiones.size)
      contador+=1
    end
    return contador
  end

  def nombre_usuario
    
    if @nombre_usuario.nil?
      dataset=@@db[:usuario_telegram].where(:id_telegram=> @id).select(:nombre_usuario)
      @nombre_usuario=dataset.first[:nombre_usuario]
    end
    return @nombre_usuario
  end

end