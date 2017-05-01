
require_relative 'menu_curso'
require_relative 'menu_chat'
require_relative '../menu_de_menus'
require_relative 'menu_tutorias_profesor'
class MenuPrincipalProfesor < MenuDeMenus

  def initialize
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
  #  @acciones[MenuCurso.nombre] = MenuCurso.new(self)
    @acciones[MenuChat.nombre] = MenuChat.new(self)
    @acciones[MenuTutoriasProfesor.nombre] = MenuTutoriasProfesor.new(self)

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

  def iniciar_acciones_defecto kb
    if @curso.size < 2
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso[0].nombre}.")
    else
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: todos cursos.")
    end
  end




end