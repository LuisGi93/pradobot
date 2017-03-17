
require_relative 'menu_cursos'
require_relative 'menu'

class MenuPrincipalProfesor < Menu

  def initialize
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[MenuCursos.nombre] = MenuCursos.new(self)
  end



end