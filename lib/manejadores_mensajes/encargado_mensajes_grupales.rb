require_relative '../contenedores_datos/mensaje'
require_relative '../moodle_api'
require_relative '../contenedores_datos/chat_telegram'

#  Clase que procesa y realiza las acciones correspondientes a los chats grupales.
# * *Args*    :
#   - mensaje -> primer mensaje que ha mandado el usuario al bot
class EncargadoMensajesGrupales
  def initialize
    @grupos = {}
  end

  #  Comprueba si un chat de Telegram está asociado a un curso controlado por el bot
  # * *Args*    :
  #   - id_chat -> identificador del chat
  #   - mensaje -> mensaje enviado desde el chat
  # * *Returns* :
  #   - Verdadero si lo está falso en caso contrario

  def comprobar_chat_registrado(id_chat, mensaje)
    nombre_chat = mensaje.nombre_chat
    chat = ChatTelegram.new(id_chat, nombre_chat)
    chat.registrado?
  end

  #  Añade un nuevo chat al conjunto de chats que están utilizando el bot
  # * *Args*    :
  #   - +id_chat+ -> identificador del chat
  #   - +nombre_chat+ -> nombre del chat de Telegram
  def dar_alta_chat(nombre_chat, id_chat)
    chat = ChatTelegram.new(id_chat, nombre_chat)
    chat.dar_de_alta
    @grupos[id_chat] = {}
    @grupos[id_chat][:curso] = chat.obtener_curso_asociado
  end

  #  Realiza una acción a partir de un nuevo mensaje que recibe desde un chat de Telegram.
  # * *Args*    :
  #   - +mensaje+ -> nuevo mensaje procedente de un chat de Telegram
  def recibir_mensaje(mensaje)
    id_chat = mensaje.id_chat
    datos_mensaje = mensaje.datos_mensaje
    if @grupos[id_chat].nil? && comprobar_chat_registrado(id_chat, mensaje)
      nombre_chat = mensaje.nombre_chat
      dar_alta_chat(nombre_chat, id_chat)
      @grupos[id_chat][:thread]= Thread.new do realizar_accion(id_chat, datos_mensaje) end
    elsif @grupos[id_chat]
      if @grupos[id_chat][:thread].alive? == false
        @grupos[id_chat][:thread]= Thread.new do realizar_accion(id_chat, datos_mensaje) end
      else
        @bot.api.send_message(chat_id: id_chat, text: "Estoy ocupado. Vuelva a intentarlo más tarde.", parse_mode: 'Markdown')
      end
    end

  end

  # Devuelve las entregas cuya fecha es proximamente
  #
  #    * *Args*    :
  #   - +entregas+ -> Array de entregas cuya fecha se va a comprobar
  # * *Returns* :
  #   - Array de Entregas
  def proximas_entregas(entregas)
    entregas_finalizadas = []
    entregas.each { |entrega|
      if Time.parse(entrega.fecha_fin) > Time.now
        entregas_finalizadas << entrega
      end
    }
    entregas_finalizadas
  end


  # Realiza la acción solicitada por un mensaje procedente de un chat grupal
  #
  #    * *Args*    :
  #   - +id_chat+ -> identificador del chat
  #   - +datos_mensaje+ -> datos del mensaje procedente del chat
  def realizar_accion(id_chat, datos_mensaje)
    case datos_mensaje
    when /\/entrega .?.?/
        datos_mensaje.slice! '/entrega'
        id_entrega = datos_mensaje.strip.to_i
        entregas_curso = proximas_entregas(@grupos[id_chat][:curso].entregas)

        if id_entrega < entregas_curso.size
          mostrar_informacion_entrega(id_chat, entregas_curso[id_entrega])
        end
    when /\/entregas$/
        entregas_curso = proximas_entregas(@grupos[id_chat][:curso].entregas)
        mostrar_entregas_del_curso(id_chat, entregas_curso)
    when /\/dudas$/
        dudas_curso = @grupos[id_chat][:curso].obtener_dudas_resueltas
        mostrar_dudas_curso id_chat, dudas_curso
    end
  end

  # Envía un mensaje a un chat mostrando las dudas resueltas de un curso
  #
  #    * *Args*    :
  #   - +id_chat+ -> identificador del chat
  #   - +dudas+ -> dudas resueltas del curso
  def mostrar_dudas_curso(id_chat, dudas)
    if dudas.empty?
      texto = 'No hay dudas para el curso.'
    else
      texto = "Dudas resueltas del curso:\n"
      dudas.each_with_index do |duda, indice|
        texto = texto + "    (*#{indice}*): \t #{duda.contenido}\n"
      end
    end

    @bot.api.send_message(chat_id: id_chat, text: texto, parse_mode: 'Markdown')
  end

  # Envía un mensaje a un chat mostrando las entregas asociadas a un curso
  #
  #    * *Args*    :
  #   - +id_chat+ -> identificador del chat
  #   - +entregas+ -> entregas a mostrar por el chat
  def mostrar_entregas_del_curso(id_chat, entregas)
    if entregas.empty?
      texto = 'Actualmente el curso no cuenta con ninguna entrega.'
    else
      texto = "Las próximas entregas son:\n"
      entregas.each_with_index do |entrega, indice|
        texto = texto + "    (*#{indice}*): \t *Nombre*: #{entrega.nombre}\n\t           *Fecha entrega*: #{entrega.fecha_fin}\n"
      end
    end

    @bot.api.send_message(chat_id: id_chat, text: texto, parse_mode: 'Markdown')
  end

  # Muestra información detallada acerca de una entrega por un chat grupal
  #
  #    * *Args*    :
  #   - +id_chat+ -> identificador del chat
  #   - +entrega+ -> entrega cuya información va a ser mostrada
  def mostrar_informacion_entrega(id_chat, entrega)
    texto = "Nombre: *#{entrega.nombre}*\n          Fecha entrega: *#{entrega.fecha_fin}*\nDescripcion:*#{entrega.descripcion}*"
      @bot.api.send_message(chat_id: id_chat, text: texto, parse_mode: 'Markdown')
  end

  # Establece el client de Telegram utilizado para mandar mensajes
  # * *Args*    :
  #   - +bot+ -> cliente de telegram utilizado para mandar mensajes
  #
  def establecer_bot(botox)
    @bot = botox
  end

end
