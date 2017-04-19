require_relative '../../../lib/acciones/menu_acciones'
require_relative 'accion_mostrar_entregas'


class MenuEntregas < MenuDeAcciones
  @nombre= 'Entregas'
  def initialize accion_padre, moodle
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones moodle
  end


  def inicializar_acciones moodle
    @acciones[AccionMostrarEntregas.nombre] = AccionMostrarEntregas.new(moodle)
  end


  private :inicializar_acciones
  public_class_method :new

end