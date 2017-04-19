
class Entrega
attr_accessor :fecha_fin, :id, :nombre, :descripcion
  def initialize fecha_fin, id, nombre
    @fecha_fin=fecha_fin
    @id=id.to_i
    @nombre=nombre
  end

  def dias_faltan
    dias_faltan=fecha_fin - DateTime.now()
  end

  def horas_faltan

  end

  def <=>(y)
    return @fecha_fin < y.fecha_fin
  end



end