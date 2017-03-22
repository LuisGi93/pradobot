require_relative 'menu'


class MenuDeAcciones < Menu
  @nombre= 'Cursos'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def cambiar_curso(curso)
    @curso=curso
    @acciones.each{|key,value|
      if value.curso!=curso
        value.curso=curso
      end
    }
    if @accion_padre.curso!=curso
      @accion_padre.cambiar_curso(curso)
    end

  end


  def accion_pulsada id_telegram,datos_mensaje

    accion_pulsada=@acciones[datos_mensaje]
    if accion_pulsada
      if @accion_pulsada
        @accion_pulsada.reiniciar
      end
      @accion_pulsada=accion_pulsada
    end
    return accion_pulsada
  end



  def obtener_siguiente_accion(id_telegram, datos_mensaje)
    siguiente_accion=nil

    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
      @accion_pulsada=nil
    else
      ha_pulsado_accion=accion_pulsada(id_telegram,datos_mensaje)

      if siguiente_accion.nil? && @accion_pulsada.nil?
        siguiente_accion=self

      else
        siguiente_accion=@accion_pulsada
      end
    end
    return siguiente_accion
  end


  def recibir_mensaje(mensaje)
    puts "Soy  #{@nombre}"
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje

    quiere_cambiar_curso=cambiar_curso_pulsado(id_telegram,datos_mensaje)

    unless quiere_cambiar_curso
      siguiente_accion=obtener_siguiente_accion(id_telegram, datos_mensaje)
      puts "La siguiente accion es #{siguiente_accion}"
      if siguiente_accion.eql? self
        ejecutar(id_telegram)
      else
        siguiente_accion.recibir_mensaje(mensaje)
      end
    end

    if siguiente_accion==@accion_padre
      return @accion_padre
    else
      return self
    end

  end


  private :inicializar_acciones

end