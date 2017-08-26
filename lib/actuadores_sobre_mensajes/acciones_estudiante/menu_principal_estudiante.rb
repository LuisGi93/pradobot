require_relative '../menu_de_menus'
require_relative '../acciones_estudiante/menu_entregas'
require_relative 'menu_tutorias'
require_relative '../menu_dudas'
class MenuPrincipalEstudiante < MenuDeMenus

  def initialize
    @acciones=Hash.new
    inicializar_acciones()
  end

  def cambiar_curso_parientes
    @acciones.each{|key,value|
      if value.curso!=@curso
        value.cambiar_curso(@curso)
      end
    }
  end

  def inicializar_acciones
    @acciones[MenuEntregas.nombre] = MenuEntregas.new(self)
    @acciones[MenuTutorias.nombre] = MenuTutorias.new(self)
    @acciones[MenuDudas.nombre] = MenuDudas.new(self)

  end



  def iniciar_acciones_defecto kb
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar de curso (#{@curso.nombre}).")
  end


  public_class_method :new
  private :inicializar_acciones


end
