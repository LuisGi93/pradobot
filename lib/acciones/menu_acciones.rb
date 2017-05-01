require_relative 'menu'


class MenuDeAcciones < Menu
  def initialize accion_padre, token_usuario
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones(token_usuario)
  end


  private






  public

  #
  # Implementa el método con el mismo nombre de link:Menu.html
  #

  def cambiar_curso_parientes
    @acciones.each{|key,value|
      if value.curso!=@curso
        puts "cambiando #{key} a #{value.curso}"
        value.curso=curso
        puts "cambiando #{key} a #{value.curso}"
      end
    }
    if @accion_padre.curso!=@curso
      @accion_padre.cambiar_curso(@curso)
    end
  end



  #
  # Si el usuario pulsa una acción del menú la establece como nueva acción activa
  # * *Args*    :
  #   - +datos_mensaje+ -> contenido del mensaje que se utiliza para comprobar si el usuario ha pulsado una nueva acción
  # * *Returns* :
  #   - Devuelve la nueva acción pulsada en caso de que la haya pulsado el usuario o nil si no es asi.
  #

  def ha_pulsado_accion datos_mensaje
    accion_pulsada=@acciones[datos_mensaje]
    if accion_pulsada
      if @accion_pulsada
        @accion_pulsada.reiniciar
      end
      @accion_pulsada=accion_pulsada
    end
  end


  #
  # Devuelve la acción que recibirá el mensaje del usuario
  # * *Args*    :
  #   - +datos_mensaje+ -> contenido del mensaje con el cual se establece que acción recibe el mensaje
  # * *Returns* :
  #   - Devuelve la acción que recibe el mensaje
  #

  def obtener_accion_recibe_mensaje(datos_mensaje)
    siguiente_accion=nil

    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
      @accion_pulsada=nil
    else
      ha_pulsado_accion(datos_mensaje)
      if siguiente_accion.nil? && @accion_pulsada.nil?
        siguiente_accion=self
      else
        siguiente_accion=@accion_pulsada
      end
    end
    return siguiente_accion
  end


  #
  # Implementa el método con el mismo nombre de link:Accion.html
  #


  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje

    quiere_cambiar_curso=cambiar_curso_pulsado(mensaje)

    unless quiere_cambiar_curso
      accion=obtener_accion_recibe_mensaje(datos_mensaje)
      if accion == self || accion==@accion_padre
        accion.ejecutar(id_telegram)
      else
        accion.recibir_mensaje(mensaje)
      end
    end

    if accion == @accion_padre
      return @accion_padre
    else
      return self
    end

  end



end