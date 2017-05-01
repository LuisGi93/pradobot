require_relative '../accion'
require_relative '../../moodle/entrega'
require_relative '../../usuarios/curso'
require_relative '../../moodle_api'
require_relative '../../usuarios/estudiante'
class AccionMostrarEntregas < Accion

  attr_reader :moodle
  @nombre='Ver proximas entregas'
  def initialize
    @estado='inicio'
    @moodle=nil
    @estudiante=nil
    @id_telegram=nil
  end


  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
    @estudiante=Estudiante.new(@id_telegram)
    @moodle=Moodle.new(@estudiante.token_moodle)
  end


  def obtener_entregas_usuario
    cursos_mostrar=Array.new
    if @curso.size < 2
      @moodle.obtener_entregas_curso(@curso[0])
      unless @curso[0].entregas.empty?
        cursos_mostrar << @curso[0]
      end
    else
      cursos_usuario=@@db[:estudiante_curso].where(:id_estudiante => @id_telegram).select(:id_curso).to_a
      cursos_usuario.each{ |id_curso|
        curso_con_entregas=obtener_entregas_curso(id_curso)
        unless curso_con_entregas.entregas.empty?
            cursos_mostrar << curso_con_entregas
        end
      }
    end

    return cursos_mostrar
  end

  def obtener_mensaje cursos_con_entregas

    texto=""
    contador=0
    if @curso.size < 2
      texto="Pulse el número de una entrega para más información. Las próximas entregas para #{@curso[0].nombre} son:\n"
      cursos_con_entregas.each{|curso|

        curso.entregas.each{|entrega|
          texto=texto+"(*#{contador}*): \n*Nombre*: #{entrega.nombre}\n  *Fecha entrega*: #{entrega.fecha_fin}\n"
          contador=contador+1
        }

      }

    else
      texto="Las próximas entregas para todos los cursos en los que se encuentra matriculado son:\n"
      cursos_con_entregas.each{|curso|

        texto+="Curso: #{curso.nombre}\n"
        curso.entregas.each{|entrega|
          texto=texto+"    (*#{contador}*): \n*Nombre*: #{entrega.nombre}\n*Fecha entrega*: #{entrega.fecha_fin}\n"
          contador=contador+1
        }

      }
    end

    return texto


  end

  def mostrar_entregas cursos_con_entregas
    kb = Array.new
    contador=0
    if cursos_con_entregas
      cursos_con_entregas.each{|curso|
        curso.entregas.each{|entrega|
          puts "Entrega id #{entrega.id}"
          kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: contador, callback_data: "entrega_#{entrega.id}_curso#{curso.id_curso}")
          contador=contador+1
        }
      }

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      mensaje = obtener_mensaje(cursos_con_entregas)
      @@bot.api.send_message( chat_id: @id_telegram, text: mensaje, reply_markup: markup, parse_mode: "Markdown")
    end
  end

  def reiniciar
  end

  def ejecutar(id_telegram)
    if @id_telegram.nil?
      establecer_id_telegram(id_telegram)
    end
    if @curso.size < 2
      cursos_con_entregas=obtener_entregas_usuario
      if cursos_con_entregas.empty?
        @@bot.api.send_message( chat_id: @id_telegram, text: "No hay ninguna entrega que mostrar para #{@curso[0].nombre}")
      else
        mostrar_entregas(cursos_con_entregas)
      end
    else
      @@bot.api.send_message( chat_id: @id_telegram, text: 'No hay cursos que mostrar.')
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