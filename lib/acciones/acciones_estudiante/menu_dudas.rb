require_relative  'solicitar_tutoria'
require_relative 'crear_duda'
require_relative '../menu_acciones'


class MenuDudas < MenuDeAcciones
  @nombre= 'Dudas'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end


  def inicializar_acciones
    @acciones[CrearDuda.nombre] = CrearDuda.new
  end
  private :inicializar_acciones

end