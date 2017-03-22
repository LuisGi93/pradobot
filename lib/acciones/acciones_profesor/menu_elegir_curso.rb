require_relative 'accion_elegir_curso'
require_relative 'menu_principal_profesor'
require_relative 'menu_acciones'


class MenuElegirCurso < MenuDeAcciones
  @nombre= 'Elegir curso'
  def initialize accion_hijo
    @accion_padre=accion_hijo
    @acciones=Hash.new
    inicializar_acciones
  end


  def inicializar_acciones
    @acciones[AccionVerCursos.nombre] = AccionElegirCurso.new()
  end

  def obtener_siguiente_accion(id_telegram, datos_mensaje)

    siguiente_accion=nil
    if /Cambiar a curso .+/ =~ datos_mensaje
      datos_mensaje.slice! "Cambiar a curso "

      siguiente_accion=AccionPrincipalProfesor.new

      siguiente_accion.cambiar_curso(@curso)
    end

    if siguiente_accion.nil? && @accion_pulsada.nil?
        siguiente_accion=self
    end

    return siguiente_accion
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=obtener_siguiente_accion(id_telegram, datos_mensaje)

    if siguiente_accion.eql? self
      ejecutar(id_telegram)
    else
      siguiente_accion.recibir_mensaje(mensaje)
    end

    return self
  end

  private :inicializar_acciones

end