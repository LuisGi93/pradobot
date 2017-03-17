require_relative 'accion_ver_cursos.rb'
require_relative 'menu'


class MenuCursos < Menu
  @nombre= 'Cursos'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[AccionVerCursos.nombre] = AccionVerCursos.new(self)
  end






  private :inicializar_acciones

end