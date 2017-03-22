require_relative 'accion_ver_cursos'
require_relative 'menu_acciones'


class MenuCurso < MenuDeAcciones
  @nombre= 'Gestionar curso'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[AccionVerCursos.nombre] = AccionVerCursos.new(@accion_padre)
  end
  private :inicializar_acciones

end