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

    #LISTAR DUDAS YA RESUELTAS
    #@actuadores_sobre_mensajes[CrearDuda.nombre] = CrearDuda.new()
    #@actuadores_sobre_mensajes[ReponderDudas.nombre] = ReponderDudas.new()
    #@actuadores_sobre_mensajes[BorrarDuda.nombre]= BorrarDuda.new()
    #@actuadores_sobre_mensajes[MarcarResultaDuda.nombre]= MarcarResueltaDuda.new()
    #Crear duda, Sin resolver, resueltas, mis dudas.
  end
  private :inicializar_acciones
end