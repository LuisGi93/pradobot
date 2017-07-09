require_relative '../accion'
require_relative '../../contenedores_datos/entrega'
require_relative '../../contenedores_datos/curso'
require_relative '../../moodle_api'
require_relative '../../contenedores_datos/estudiante'
class VerCalificacionEntregas < Accion

  attr_reader :moodle
  @nombre='Ver calificacion entrega'
  def initialize
    @estado='inicio'
    @moodle=nil
    @estudiante=nil
    @id_telegram=nil
  end


  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
    @estudiante=Estudiante.new(@id_telegram)
  end


  def obtener_mensaje cursos_con_entregas

    texto=""
    contador=0
    texto="Pulse el número de una entrega para más información. Las próximas entregas para #{@curso.nombre} son:\n"
    cursos_con_entregas.each{|curso|

      curso.entregas.each{|entrega|
        texto=texto+"(*#{contador}*): \n*Nombre*: #{entrega.nombre}\n  *Fecha entrega*: #{entrega.fecha_fin}\n"
        contador=contador+1
      }

    }

    return texto


  end

  def mostrar_entregas entregas
    text="Las entregas para *#{@curso.nombre}* actualmente se encuentran en el siguiente estado:\n"
    entregas.each_with_index{|entrega, index|
          text+=" #{index})   Entrega: *#{entrega.nombre}*\n       Nota: *#{@estudiante.consultar_nota_entrega(entrega)}*\n"
        }

     @@bot.api.send_message( chat_id: @id_telegram, text: text, parse_mode: "Markdown")
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

  def ejecutar(id_telegram)
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    entregas_curso=@curso.entregas
    entregas_finalizadas=obtener_entregas_finalizadas(entregas_curso)
    if entregas_finalizadas.empty?
      @@bot.api.send_message( chat_id: @id_telegram, text: "No hay ninguna entrega que haya finalizado y sea posible mostrar nota en #{@curso.nombre}")
    else
      mostrar_entregas(entregas_finalizadas)
    end
  end


  def mostrar_informacion_entrega entrega, curso, mensaje
    entrega=@moodle.obtener_entrega(entrega, curso)
    if entrega
      texto="*Nombre:* #{entrega.nombre}
*Fecha entrega:* #{entrega.fecha_fin}
*Descripcion*:#{entrega.descripcion}"
    else
      texto="Error"
    end
    @@bot.api.answer_callback_query(callback_query_id: mensaje.obtener_identificador_mensaje, text: "Ok!")
    @@bot.api.send_message( chat_id: @id_telegram, text: texto, parse_mode: 'Markdown' )
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    if datos_mensaje  =~ /entrega_.+/
      datos_mensaje.slice! "entrega_"
      id_entrega=datos_mensaje[/[0-9]{1,2}/]
      datos_mensaje.slice! /[0-9]{1,2}/

      datos_mensaje.slice! "_curso"
      id_curso=datos_mensaje[/[0-9]{1,2}/]
      entrega=Entrega.new(id_entrega)
      curso=Curso.new(id_curso)
      mostrar_informacion_entrega(entrega, curso, mensaje)
    else
      ejecutar(@id_telegram)
    end

  end

  public_class_method :new

end
