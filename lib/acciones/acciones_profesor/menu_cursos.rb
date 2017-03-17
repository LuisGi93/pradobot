require_relative 'accion_ver_cursos.rb'
require_relative 'menu_principal_profesor'
require_relative 'accion_profesor'


class MenuCursos < AccionProfesor
  @nombre= 'Cursos'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end

  def inicializar_acciones
    @acciones[AccionVerCursos.nombre] = AccionVerCursos.new(self)
  end

  def ejecutar(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=nil
    if @acciones[datos_mensaje]
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      @@bot.api.send_message(chat_id: id_telegram, text: 'Sorry to see you go :(', reply_markup: kb)
      siguiente_accion=@acciones[datos_mensaje]

    elsif datos_mensaje== "Atras"
      siguiente_accion=@accion_padre
    else
      kb= Array.new
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

  def self.nombre
     @nombre
  end



  private :inicializar_acciones

end