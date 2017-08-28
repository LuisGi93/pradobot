module MenuInlineTelegram
  def self.crear(acciones)
    fila_botones = []
    array_botones = []
    acciones.each do |accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{accion}")
      if array_botones.size == 3
        fila_botones << array_botones.dup
        array_botones.clear
      end
    end
    fila_botones << array_botones
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    markup
  end

  def self.crear_menu_indice(acciones, prefijo, tipo)
    fila_botones = []
    array_botones = []
    acciones.each do |accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{prefijo} #{accion}")
      if array_botones.size == 4
        fila_botones << array_botones.dup
        array_botones.clear
      end
    end

    if tipo == 'final'
      fila_botones << array_botones
    else
      fila_botones << array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Volver', callback_data: "#\#$$Volver")
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    markup
  end
end
