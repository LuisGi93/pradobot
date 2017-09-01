

#
# Librería utilizada para crear menús inline de Telegram genéricos.
# #
module MenuInlineTelegram

  #    
    # Genera un menú Inline con cadenas de texto en sus botonos
    #    *Args*    :
    #   - +acciones+ -> Array que contiene las Strings que se van a mostrar en los botones
    #
  #* *Returns* :
  #   - Menu tipo Inline de Telegram  #
  #   
  #

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

  #    
    # Genera un menú Inline con botones numéricos 
    #    *Args*    :
    #   - +acciones+ -> Array de enteros utilizados para mostrar en los botones 
    #   - +prefijo+ -> Prefijo utilizado para distinguir que simbolizan los botones 
  # #   - +tipo+ -> indica si el menú tiene un menú anterior o no. 
  #* *Returns* :
  #   - Menu tipo Inline de Telegram  #
  #   
  #
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
