class Entrega
attr_accessor :fecha_fin, :id, :nombre, :descripcion


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


  def <=>(y)
    return @fecha_fin < y.fecha_fin
  end





end

