
require_relative 'menu_chat'
require_relative '../menu_dudas'
require_relative '../menu_de_menus'
require_relative 'menu_tutorias_profesor'
class MenuPrincipalProfesor < MenuDeMenus
  def initialize
    @acciones = {}
    inicializar_acciones
  end

  private

  def inicializar_acciones
    @acciones[MenuChat.nombre] = MenuChat.new(self)
    @acciones[MenuTutoriasProfesor.nombre] = MenuTutoriasProfesor.new(self)
    @acciones[MenuDudas.nombre] = MenuDudas.new(self)
  end

  def cambiar_curso_parientes
    @acciones.each do |_key, value|
      value.cambiar_curso(@curso) if value.curso != @curso
    end
  end

  def iniciar_acciones_defecto(kb)
    kb << Telegram::Bot::Types::KeyboardButton.new(text: "Cambiar de curso. Curso actual: #{@curso.nombre}.")
  end
end
