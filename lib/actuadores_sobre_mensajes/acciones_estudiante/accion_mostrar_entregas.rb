require_relative '../accion'
require_relative '../../contenedores_datos/entrega'
require_relative '../../contenedores_datos/curso'
require_relative '../../moodle_api'
require_relative '../../contenedores_datos/estudiante'
require_relative '../menu_inline_telegram.rb'

class AccionMostrarEntregas < Accion
  attr_reader :moodle
  @nombre = 'Ver proximas entregas'
  def initialize
    @fase = ''
    @ultimo_mensaje = nil
  end

  def obtener_mensaje
    texto = ''
    contador = 0
    texto = "Pulse el número de una entrega si quiere ver su descripción. Las próximas entregas para #{@curso.nombre} son:\n"

    @entregas.each do |entrega|
      texto += "(*#{contador}*)  *Nombre*: #{entrega.nombre}\n      *Fecha entrega*  #{entrega.fecha_fin}\n"
      contador += 1
    end

    texto
  end

  def mostrar_entregas(opcion)
    indices = [*0..@entregas.size - 1]

    menu = MenuInlineTelegram.crear_menu_indice(indices, 'Entrega', 'final')
    texto = obtener_mensaje
    if opcion == 'editar_mensaje'
      @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, reply_markup: menu, parse_mode: 'Markdown')
    else
      @@bot.api.send_message(chat_id: @ultimo_mensaje.usuario.id_telegram, text: texto, reply_markup: menu, parse_mode: 'Markdown')
    end
  end

  def reiniciar
    @entregas.clear
  end

  def mostrar_informacion_entrega(entrega)
    texto = if entrega.descripcion
              "*Nombre:* #{entrega.nombre}
        *Fecha entrega:* #{entrega.fecha_fin}
        *Descripcion*:#{entrega.descripcion}"
            else
              "#{entrega.nombre} no cuenta con ninguna descripción."
            end
    acciones = ['Volver']
    menu = MenuInlineTelegram.crear(acciones)
    @@bot.api.edit_message_text(chat_id: @ultimo_mensaje.id_chat, message_id: @ultimo_mensaje.id_mensaje, text: texto, reply_markup: menu, parse_mode: 'Markdown')
  end

  def recibir_mensaje(mensaje)
    @ultimo_mensaje = mensaje
    datos_mensaje = @ultimo_mensaje.datos_mensaje
    # puts datos_mensaje
    case datos_mensaje
    when /\#\#\$\$Entrega/
      datos_mensaje.slice! "#\#$$Entrega"
      datos_mensaje = datos_mensaje.to_i
      @@bot.api.answer_callback_query(callback_query_id: @ultimo_mensaje.id_callback, text: 'Obteniendo información entrega...')
      mostrar_informacion_entrega(@entregas.at(datos_mensaje))
      @fase = 'mostrar_entregas'
    when /\#\#\$\$Volver/
      mostrar_entregas('editar_mensaje')
      @fase = ''
    else
      @fase = ''
      @entregas = @curso.entregas
      mostrar_entregas('nuevo_mensaje')
    end
  end

  public_class_method :new
  private :mostrar_entregas, :mostrar_informacion_entrega
end
