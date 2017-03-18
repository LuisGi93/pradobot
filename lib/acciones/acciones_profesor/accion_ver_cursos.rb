require_relative 'accion_profesor'

class AccionVerCursos< AccionProfesor

  @nombre='Ver cursos'
  def initialize accion_padre
    @accion_padre=accion_padre
  end

  def ejecutar(id_telegram)

  end

end