require_relative '../accion'
require_relative '../../contenedores_datos/entrega'
require_relative '../../contenedores_datos/curso'
require_relative '../../moodle_api'
require_relative '../../contenedores_datos/estudiante'
require_relative '../menu_inline_telegram.rb'

#
# Clase que contiene los pasos necesarios para que el usuario pueda obtener información general de las entregas de un curso
#
class AccionMostrarEntregas < Accion
  attr_reader :moodle
  @nombre = 'Ver próximas entregas'
  def initialize
    @fase = ''
    @ultimo_mensaje = nil
  end
# 
  #
  # Crea un mensaje a partir de las entregas del curso 
  # * *Returns* :
  #   - String con que contiene la fecha de las proximas entregas  #
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

# 
  #
  # Envía un mensaje al usuario con un menú tipo Inline que muestra información de las próximas entregas.
  #  *Args* :
  #  - +opcion+ -> Determina si se envía un nuevo mensaje o se edita el último enviado+
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

#
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

  def reiniciar
    @entregas.clear
  end

  # Envía al usuario un mensaje en el que se muestra la información de una entrega.
  #   # * *Args*    :
  #   - +entrega+ -> entrega sobre la cual se muestra información
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

  #
  #   Implementa el método con el mismo nombre de link:Accion.html
  #    
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
      @entregas = proximas_entregas(@curso.entregas)
      mostrar_entregas('nuevo_mensaje')
    end
  end

  public_class_method :new
  private :mostrar_entregas, :mostrar_informacion_entrega
end
