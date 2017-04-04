require_relative  'accion_asociar_chat'
require_relative '../menu_acciones'


class MenuChat < MenuDeAcciones
  @nombre= 'Chat Telegram'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[AccionAsociarChat.nombre] = AccionAsociarChat.new(@accion_padre)
  end
  private :inicializar_acciones

end