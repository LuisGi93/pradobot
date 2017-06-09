
require_relative 'menu_curso'
require_relative 'menu_chat'
require_relative '../menu_dudas'
require_relative '../menu_de_menus'
require_relative 'menu_tutorias_profesor'
class MenuPrincipalProfesor < MenuDeMenus

  def initialize
    @acciones=Hash.new
    inicializar_acciones
  end

  private
  def inicializar_acciones
  #  @actuadores_sobre_mensajes[MenuCurso.nombre] = MenuCurso.new(self)
    @acciones[MenuChat.nombre] = MenuChat.new(self)
    @acciones[MenuTutoriasProfesor.nombre] = MenuTutoriasProfesor.new(self)
    @acciones[MenuDudas.nombre] = MenuDudas.new(self)
  end


  def cambiar_curso_parientes
    @acciones.each{|key,value|
      if value.curso!=@curso
        value.cambiar_curso(@curso)
      end
    }
  end

  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso.nombre}.")

  end




end