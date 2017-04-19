
require_relative 'menu_curso'
require_relative 'menu_chat'
require_relative '../menu_de_menus'
class MenuPrincipalProfesor < MenuDeMenus

  def initialize
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
  #  @acciones[MenuCurso.nombre] = MenuCurso.new(self)
    @acciones[MenuChat.nombre] = MenuChat.new(self)
  end

  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso['nombre_curso']}", )
  end




end