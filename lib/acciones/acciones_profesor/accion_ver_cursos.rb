require_relative 'accion_profesor'

class AccionVerCursos< Accion

  @nombre='Ver cursos'
  def initialize accion_padre
    @accion_padre=accion_padre
  end

  def ejecutar(mensaje)

  end

end