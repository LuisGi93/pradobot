
require_relative 'menu_cursos'
require_relative 'accion_profesor'

class MenuPrincipalProfesor < AccionProfesor

  def initialize
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[MenuCursos.nombre] = MenuCursos.new(self)
  end

  def ejecutar(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=nil
    if @acciones[datos_mensaje]
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      @@bot.api.send_message(chat_id: id_telegram, text: 'Sorry to see you go :(', reply_markup: kb)

      siguiente_accion=@acciones[datos_mensaje]
      puts "La siguiente accion es#{siguiente_accion.class.to_s}"
    else
        kb= Array.new
        puts "Muestro las llaves#{@acciones.keys.to_s}"
        @acciones.keys.each{
            |accion|

          kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
        }
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
        @@bot.api.send_message( chat_id: id_telegram, text: 'Algo', reply_markup: markup)
        siguiente_accion=self

    end
    return siguiente_accion

  end

end