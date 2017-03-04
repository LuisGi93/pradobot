
require_relative '../procesadores_entradas/procesador_entradas_profesor'
require_relative '../usuarios/profesor'
require_relative '../estado/profesor'

class ManejadorMensajesDesconocido

  def initialize()
    @estado_usuarios_profesor=EstadoProfesor.new
    @desconocido=Desconocido.new(@estado_usuarios_profesor)
  end

  def recibir_mensaje(mensaje,bot)

    #estado_admin=@estado_usuarios_administrador.obtener_estado_actual(mensaje.from.id)

    if(false)

    else
      @desconocido.inicializar_usuario(mensaje, bot)

    end
  end

end