

require_relative '../mensaje'
require_relative '../acciones/accion'
require_relative '../acciones/acciones_profesor/accion_elegir_curso'
require_relative '../../lib/acciones/acciones_profesor/menu_principal_profesor'

class ManejadorMensajesProfesor

  def initialize()

    @profesores=Hash.new
  end

  def recibir_mensaje(mensaje,bot)
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
#no se tiene que pasar profesores sino que es self lo que se pasa es self
    #Quiero que todas las acciones y los menus tengan el mismo curso
    #Lo que quiero es que cada instancia de menu tenga una variable diferente
    #El curso esta asociado a la instancia concreta
  end

end