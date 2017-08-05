require_relative '../accion'
require_relative '../../contenedores_datos/entrega'
require_relative '../../contenedores_datos/curso'
require_relative '../../moodle_api'
require_relative '../../contenedores_datos/estudiante'

class VerCalificacionEntregas < Accion

  attr_reader :moodle
  @nombre='Ver calificacion entrega'
  def initialize
    @ultimo_mensaje=nil
  end

  def reiniciar
  end

  def obtener_entregas_finalizadas entregas

    entregas_finalizadas=Array.new
    entregas.each{|entrega|
      if  Time.parse(entrega.fecha_fin) < Time.now
        entregas_finalizadas << entrega
      end
    }
    return entregas_finalizadas
  end



  def mostrar_calificaciones entregas
     text="Las entregas para *#{@curso.nombre}* actualmente se encuentran en el siguiente estado:\n"
     entregas.each_with_index{|entrega, index|
     text+=" #{index})   Entrega: *#{entrega.nombre}*\n       Nota: *#{Estudiante.new(@ultimo_mensaje.usuario.id_telegram).consultar_nota_entrega(entrega)}*\n"                      }
    @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: text, parse_mode: "Markdown")
  end

  def mostrar_entregas_finalizadas
    entregas_curso=@curso.entregas
    entregas_finalizadas=obtener_entregas_finalizadas(entregas_curso)
    if entregas_finalizadas.empty?
      @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: "No hay ninguna entrega que haya finalizado y sea posible mostrar nota en #{@curso.nombre}")
    else
      mostrar_calificaciones(entregas_finalizadas)
    end
  end


  def recibir_mensaje(mensaje)
      @ultimo_mensaje=mensaje
      mostrar_entregas_finalizadas
  end

  public_class_method :new

end
