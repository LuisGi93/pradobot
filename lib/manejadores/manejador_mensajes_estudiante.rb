require_relative '../acciones/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/acciones/accion'
class ManejadorMensajesEstudiante < Accion

  def initialize
    @estudiantes=Hash.new
  end
  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    accion=@estudiantes[id_telegram]
    if accion
      estado=accion[:thread].status
      if estado == false || estado.nil?
        @estudiantes[id_telegram][:accion]=accion[:thread].value
        @estudiantes[id_telegram][:thread]= Thread.new do @estudiantes[id_telegram][:accion].recibir_mensaje(mensaje) end
      else
        @@bot.api.send_message( chat_id: id_telegram, text: "Acción anterior aún en proceso espere unos momentos")
      end

    else
      @estudiantes[id_telegram]=Hash.new
      @estudiantes[id_telegram][:accion]=AccionElegirCurso.new(MenuPrincipalEstudiante.new(234234))
      @estudiantes[id_telegram][:thread]= Thread.new do @estudiantes[id_telegram][:accion].ejecutar(id_telegram) end
    end
  end
  public_class_method :new

end