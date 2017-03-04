
require_relative '../procesadores_entradas/procesador_entradas_administrador'
require_relative '../usuarios/admin'
require_relative '../estado/admin'

class ManejadorMensajesAdministrador

  def initialize()

    @procesador_entradas=ProcesadorEntradasAdministrador.new()
    @estado_usuarios_administrador=EstadoAdmin.new
    @admin=Admin.new(@estado_usuarios_administrador)
  end

  def recibir_mensaje(mensaje,bot)

    estado_admin=@estado_usuarios_administrador.obtener_estado_actual(mensaje.from.id)

    if(@procesador_entradas.quiere_dar_alta_profesor(mensaje,estado_admin))
       @admin.dar_alta_profesor(mensaje, bot)
    else
      kb = [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Dar de alta profesor', callback_data: 'alta_profesor'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Dar de alta alumnos', callback_data: 'alta_alumnos'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Switch to inline', switch_inline_query: 'some text')
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      tipo_mensaje=mensaje.class

      if (tipo_mensaje == Telegram::Bot::Types::CallbackQuery)
        bot.api.send_message( chat_id: mensaje.message.chat.id, text: 'Make a choice', reply_markup: markup)

      else

          bot.api.send_message(chat_id: mensaje.chat.id, text: 'Make a choice', reply_markup: markup)
        end
    end
  end

end