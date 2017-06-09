require_relative '../moodle_api'
class Entrega
attr_accessor :fecha_fin, :id, :nombre, :descripcion

@moodle=Moodle.new(ENV['TOKEN_BOT_MOODLE'])

  def initialize id, fecha_fin=nil, nombre=nil
    @fecha_fin=fecha_fin
    @id=id.to_i
    @nombre=nombre
    @descripcion=nil
    @curso=nil
  end

  def dias_faltan
    dias_faltan=fecha_fin - DateTime.now()
  end

  def horas_faltan

  end

  def <=>(y)
    return @fecha_fin < y.fecha_fin
  end


  def nota_entrega

  end



end

