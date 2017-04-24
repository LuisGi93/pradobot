require_relative '../accion'
require_relative '../../moodle/entrega'
require_relative '../../moodle/curso'
require_relative '../../moodle_api'
require_relative '../../usuarios/estudiante'
class AccionMostrarEntregas < Accion

  attr_reader :moodle
  @nombre='Ver proximas entregas'
  def initialize
    @estado='inicio'
    @moodle=nil
    @id_telegram=nil
  end


  def establecer_id_telegram(id_telegram)
    @id_telegram=id_telegram
    estudiante=Estudiante.new(@id_telegram)
    @moodle=Moodle.new(estudiante.token_moodle)
  end


  def obtener_entregas_usuario
    cursos_mostrar=Array.new
    if @curso['id_moodle'].to_i >=0
      id_curso=@@db[:estudiante_curso].where(:id_moodle_curso => @curso['id_moodle'].to_i).first[:id_moodle_curso]
      puts "El id del curso #{@curso['id_moodle'].to_i}"
      curso_con_entregas=@moodle.obtener_entregas_curso(id_curso)
      unless curso_con_entregas.entregas.empty?
        cursos_mostrar << curso_con_entregas
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
    if @curso['id_moodle'].to_i >=0
      texto="Las próximas entregas para #{@curso['nombre']} son:\n"
      cursos_con_entregas.each{|curso|

        curso.entregas.each{|entrega|
          texto=texto+"(*#{contador}*): \n*Nombre*: #{entrega.nombre}\n*Fecha entrega*: #{entrega.fecha_fin}\n"
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
    cursos=@@db[:estudiante_curso].where(:id_estudiante => @id_telegram).to_a
    if cursos && cursos.size > 0
      cursos_con_entregas=obtener_entregas_usuario
      if cursos_con_entregas.empty?
        @@bot.api.send_message( chat_id: @id_telegram, text: "No hay ninguna entrega que mostrar para #{@curso['nombre']}")
      else
        mostrar_entregas(cursos_con_entregas)
      end
    else
      @@bot.api.send_message( chat_id: @id_telegram, text: 'No hay cursos que mostrar.')
    end
  end


  def mostrar_informacion_entrega id_entrega, id_curso
    entrega=@moodle.obtener_entrega(id_entrega, id_curso)
    if entrega
      texto="*Nombre:* #{entrega.nombre}
*Fecha entrega:* #{entrega.fecha_fin}
*Descripcion*:#{entrega.descripcion}"
    else
      texto="Error"
    end
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
      mostrar_informacion_entrega(id_entrega.to_i, id_curso.to_i)
    else
      ejecutar(@id_telegram)
    end

  end

  public_class_method :new

end