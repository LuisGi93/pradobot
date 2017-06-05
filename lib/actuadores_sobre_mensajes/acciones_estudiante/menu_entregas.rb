require_relative '../../../lib/actuadores_sobre_mensajes/menu_acciones'
require_relative 'accion_mostrar_entregas'
require_relative 'accion_calificacion_entregas'


class MenuEntregas < MenuDeAcciones
  @nombre= 'Entregas'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end


  def inicializar_acciones
    @acciones[AccionMostrarEntregas.nombre] = AccionMostrarEntregas.new
    @acciones[VerCalificacionEntregas.nombre] = VerCalificacionEntregas.new
  end


  private :inicializar_acciones
  public_class_method :new

end