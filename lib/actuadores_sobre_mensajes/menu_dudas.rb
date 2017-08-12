require_relative 'listar_dudas_pendientes.rb'
require_relative 'listar_mis_dudas.rb'
require_relative 'listar_dudas_resueltas'
require_relative 'crear_duda'
require_relative 'menu_acciones'


class MenuDudas < MenuDeAcciones
  @nombre= 'Dudas'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[CrearDuda.nombre] = CrearDuda.new() #CREAR NUEVA DUDA
    @acciones[ListarDudasPendientes.nombre]=ListarDudasPendientes.new()
    @acciones[ListarMisDudas.nombre]=ListarMisDudas.new()
    @acciones[ListarDudasResueltas.nombre]=ListarDudasResueltas.new()

  end
  private :inicializar_acciones
end
