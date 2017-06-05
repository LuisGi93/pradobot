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
    puts "Los cursos del usuario son #{@curso.to_s}"

    @acciones.each{|key,value|
      if value.curso!=@curso
        puts "cambiando #{key} a #{value.curso}"
        value.cambiar_curso(@curso)
        puts "cambiando #{key} a #{value.curso}"
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


end
