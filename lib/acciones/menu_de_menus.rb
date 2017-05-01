
require_relative 'menu'

class MenuDeMenus < Menu

  def cambiar_curso_parientes
    @acciones.each{|key,value|
      if value.curso!=@curso
        puts "cambiando #{key} a #{value.curso}"
        value.cambiar_curso(@curso)
        puts "cambiando #{key} a #{value.curso}"
      end
    }
    if @accion_padre.curso!=@curso
      @accion_padre.cambiar_curso(@curso)
    end
  end


  def accion_pulsada id_telegram,datos_mensaje
    accion=@acciones[datos_mensaje]
    if accion
      @accion_pulsada=accion
      @@bot.api.send_message(chat_id: id_telegram, text: datos_mensaje)
    end
    return accion

  end

  def obtener_siguiente_accion(id_telegram, datos_mensaje)
    siguiente_accion=nil

    if datos_mensaje== "Atras" && @accion_padre
      siguiente_accion=@accion_padre
    else
      siguiente_accion=accion_pulsada(id_telegram,datos_mensaje)
      puts "Accion pulsada #{siguiente_accion}"
      if siguiente_accion.nil?
        siguiente_accion=self
      end
    end

    return siguiente_accion
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if cambiar_curso_pulsado(mensaje)
      siguiente_accion=self
    else
      siguiente_accion=obtener_siguiente_accion(id_telegram, datos_mensaje)
      siguiente_accion.ejecutar(id_telegram)
    end

    return siguiente_accion
  end










end





