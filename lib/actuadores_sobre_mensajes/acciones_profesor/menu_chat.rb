require_relative 'accion_asociar_chat'
require_relative '../menu_acciones'

class MenuChat < MenuDeAcciones
  @nombre = 'Chats asociados cursos'
  def initialize(accion_padre)
    @accion_padre = accion_padre
    @acciones = {}
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[AccionAsociarChat.nombre] = AccionAsociarChat.new
  end
  private :inicializar_acciones
end
