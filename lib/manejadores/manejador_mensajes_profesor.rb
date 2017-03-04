
require_relative '../procesadores_entradas/procesador_entradas_profesor'
require_relative '../usuarios/profesor'
require_relative '../estado/profesor'

class ManejadorMensajesProfesor

  def initialize()

    @procesador_entradas=ProcesadorEntradasProfesor.new()
    @estado_usuarios_profesor=EstadoProfesor.new
    @profesor=Profesor.new(@estado_usuarios_profesor)
  end

  def recibir_mensaje(mensaje,bot)

    #estado_admin=@estado_usuarios_administrador.obtener_estado_actual(mensaje.from.id)

    if(false)

    else
      @profesor.inicializar_profesor(mensaje, bot)

    end
  end

end