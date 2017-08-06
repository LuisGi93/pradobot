module MenuInlineTelegram



  def MenuInlineTelegram.crear(acciones)
    fila_botones=Array.new
    array_botones=Array.new
    acciones.each{|accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{accion}")
      if array_botones.size == 3
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }
    fila_botones << array_botones
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    return markup
  end

  def MenuInlineTelegram.crear_menu_indice (acciones, prefijo, tipo)
    fila_botones=Array.new
    array_botones=Array.new
    acciones.each{|accion|
      array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: accion, callback_data: "#\#$$#{prefijo} #{accion}")
      if array_botones.size == 4
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }

    if(tipo =="final")
      fila_botones << array_botones
    else
      fila_botones << array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Volver", callback_data: "#\#$$Volver")
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)
    return markup
  end





end
