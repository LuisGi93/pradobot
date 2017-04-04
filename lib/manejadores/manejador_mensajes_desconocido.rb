
require_relative '../acciones/accion_inicializar_desconocido'

class ManejadorMensajesDesconocido

  def initialize()
    @desconocidos=Hash.new
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    accion=@desconocidos[id_telegram]
    if accion
      @desconocidos[id_telegram]=accion.recibir_mensaje(mensaje)
    else
      @desconocidos[id_telegram]=AccionInicializarDesconocido.new()
      @desconocidos[id_telegram].ejecutar(id_telegram)
    end

  end

end