
require_relative 'menu'

#
# Simboliza un menú en el que la mayoría de opciones despliegan otros menús.
#
class MenuDeMenus < Menu



  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje
    datos_mensaje=mensaje.datos_mensaje
    if cambiar_curso_pulsado(mensaje)
      siguiente_accion=self
    else
      siguiente_accion=obtener_siguiente_opcion
      siguiente_accion.ejecutar(mensaje)
    end

    return siguiente_accion
  end


  private


  def opcion_pulsada 
    accion=@acciones[@ultimo_mensaje.datos_mensaje]
    if accion
      @accion_pulsada=accion
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: @ultimo_mensaje.datos_mensaje)
    end
    return accion

  end

  def obtener_siguiente_opcion
      siguiente_accion=opcion_pulsada
      if siguiente_accion.nil?
        siguiente_accion=self
      end

    return siguiente_accion
  end










end





