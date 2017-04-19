

require_relative '../mensaje'
require_relative '../acciones/accion'
require_relative '../acciones/accion_elegir_curso'
require_relative '../../lib/acciones/acciones_profesor/menu_principal_profesor'

class ManejadorMensajesProfesor

  def initialize()

    @profesores=Hash.new
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    accion=@profesores[id_telegram]
    puts "se va a ejecutar #{accion}"
    if accion
      @profesores[id_telegram]=accion.recibir_mensaje(mensaje)
      puts "recibido #{accion}"
      puts "recibido #{@profesores[id_telegram]}"

    else
      @profesores[id_telegram]=AccionElegirCurso.new(MenuPrincipalProfesor.new)
      @profesores[id_telegram]=@profesores[id_telegram].ejecutar(id_telegram)
    end

  end

end