require_relative '../contenedores_datos/mensaje'
require_relative '../moodle_api'
require_relative '../actuadores_sobre_mensajes/chat_curso'
require_relative '../contenedores_datos/chat_telegram'

class EncargadoMensajesGrupales

  def initialize  #se puede meter aqui lo relacionado con accion_chat si solamente se van a llamar funciones en los hijos de accion_chat
    @grupos=Hash.new  #! tienen que ser instanciadas las actuadores_sobre_mensajes asociadas a los chats privados/menus ya que suelen tener estado interno, otra cosa es que se pueda hacer una jearquia
    #@chat_curso=ChatCurso.new(Moodle.new(ENV['TOKEN_BOT_MOODLE']))
  end

  #La única forma de identificar al chat es por su nombre ya que es lo único que se le permite ver al usuario profesor, no es posible por ejemplo obtener los nombres
  # de los usuarios de un chat.

  def comprobar_chat_registrado id_chat, mensaje
    nombre_chat=mensaje.obtener_nombre_chat
    chat=ChatTelegram.new(id_chat, nombre_chat)
    return chat.registrado?
  end

  def dar_alta_chat nombre_chat, id_chat
    chat=ChatTelegram.new(id_chat, nombre_chat)
    chat.dar_de_alta
    @grupos[id_chat]=Hash.new
    @grupos[id_chat][:curso]= chat.obtener_curso_asociado
  end

  def recibir_mensaje(mensaje)

   # Thread.new do @estudiantes[id_telegram][:accion].recibir_mensaje(mensaje) end
    id_chat=mensaje.obtener_identificador_chat
    datos_mensaje=mensaje.obtener_datos_mensaje
    if @grupos[id_chat].nil? && comprobar_chat_registrado(id_chat, mensaje)
      nombre_chat=mensaje.obtener_nombre_chat
      dar_alta_chat(nombre_chat, id_chat)
      realizar_accion(id_chat, datos_mensaje)
    elsif @grupos[id_chat]
      #debu mode #estado=@grupos[id_chat].status

      if true #debug mode #estado == false || estado.nil?
        #debug mode#@grupos[id_chat][:thread]= Thread.new do realizar_accion(id_chat, datos_mensaje) end
        realizar_accion(id_chat, datos_mensaje)
      end
    end


  end

  def realizar_accion(id_chat, datos_mensaje)
    puts "Los datos del mensaje son #{datos_mensaje}"
    case datos_mensaje
      when /\/entrega .?.?/
        datos_mensaje.slice! "/entrega"
        id_entrega=datos_mensaje.strip.to_i


        entregas_curso=@grupos[id_chat][:curso].entregas
        if id_entrega < entregas_curso.size
          mostrar_informacion_entrega(id_chat, entregas_curso[id_entrega])
        end
      when /\/entregas$/
        entregas_curso=@grupos[id_chat][:curso].entregas
        mostrar_entregas_del_curso(id_chat, entregas_curso)
        #@chat_curso.mostrar_entregas_del_curso(id_chat, @grupos[id_chat])
      when /\/dudas$/
        dudas_curso=@grupos[id_chat][:curso].obtener_dudas_sin_resolver
        mostrar_dudas_curso id_chat, dudas_curso
    end

  end


  def mostrar_dudas_curso id_chat, dudas
    if dudas.empty?
      texto="No hay dudas para el curso."
    else
      texto="Dudas pendientes de ser contestadas:\n"
      dudas.each_with_index { |duda, indice|
        texto=texto+"    (*#{indice}*): \t #{duda.contenido}\n"
      }
    end

    @bot.api.send_message( chat_id: id_chat, text: texto, parse_mode: 'Markdown' )

  end



  def mostrar_entregas_del_curso id_chat, entregas
    if entregas.empty?
      texto="Actualmente el curso no cuenta con ninguna entrega."
    else
      texto="Las próximas entregas son:\n"
      entregas.each_with_index { |entrega, indice|
        texto=texto+"    (*#{indice}*): \t *Nombre*: #{entrega.nombre}\n\t           *Fecha entrega*: #{entrega.fecha_fin}\n"
      }
    end

    @bot.api.send_message( chat_id: id_chat, text: texto, parse_mode: 'Markdown' )

  end


  def mostrar_informacion_entrega id_chat, entrega
      texto="Nombre: *#{entrega.nombre}*\n          Fecha entrega: *#{entrega.fecha_fin}*\nDescripcion:*#{entrega.descripcion}*"
    @bot.api.send_message( chat_id: id_chat, text: texto, parse_mode: 'Markdown' )
  end



  def establecer_bot botox
    @bot=botox
   # @chat_curso.establecer_bot(botox)
  end



end