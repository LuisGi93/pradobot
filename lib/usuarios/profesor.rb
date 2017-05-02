
require_relative 'usuario'

class Profesor < Usuario
  attr_reader :id
  def initialize id_telegram=nil
    @id=id_telegram
    @nombre_usuario=nil
  end

  def solicitar_tutoria peticion

    aceptada=true
    begin
      puts Time.new.strftime("%Y-%m-%d %H:%M:%S")
      @@db[:peticion_tutoria].where(:id_profesor => @id, :dia_semana_hora => peticion.tutoria.fecha)
        .insert(:id_profesor => @id, :dia_semana_hora => peticion.tutoria.fecha, :id_estudiante => peticion.estudiante.id, :hora_solicitud => Time.new.strftime("%Y-%m-%d %H:%M:%S"), :estado => "por aprobar")
    rescue  Sequel::ForeignKeyConstraintViolation, Sequel::UniqueConstraintViolation => boom
      aceptada=false

    end
    return aceptada
  end

  def obtener_tutorias
      tutorias=Array.new
      datos_tutorias=@@db[:tutoria].where(:id_profesor => @id).to_a
      datos_tutorias.each{ |tutoria|
        tutorias << Tutoria.new(self, tutoria[:dia_semana_hora])
      }
    return tutorias
  end




  def establecer_nueva_tutoria  tutoria
    puts tutoria.fecha
    puts tutoria.fecha
    existe_tutoria=@@db[:tutoria].where(:id_profesor => @id, :dia_semana_hora => tutoria.fecha)
    if existe_tutoria.empty?
      @@db[:tutoria].insert(:id_profesor => @id, :dia_semana_hora => tutoria.fecha)
    end
  end

  def borrar_tutoria tutoria
    @@db[:tutoria].where(:id_profesor => @id, :dia_semana_hora => tutoria.fecha).delete
  end

end

require_relative 'tutoria'