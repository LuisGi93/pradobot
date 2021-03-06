require_relative '../actuadores_sobre_mensajes/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/actuadores_sobre_mensajes/accion'
require_relative '../../lib/contenedores_datos/usuario_desconocido'
require_relative '../../lib/actuadores_sobre_mensajes/acciones_profesor/menu_principal_profesor'
require_relative '../../lib/actuadores_sobre_mensajes/accion_inicializar_desconocido'
require_relative '../../lib/contenedores_datos/usuario_registrado'
#
#  Clase encargada
# * *Args*    :
#   - ++ ->
# * *Returns* :
#   -
# * *Raises* :
#   - ++ ->
#

#
#  Clase encargada de dirigir el tráfico de mensajes recibido desde los chats privados.

class EncargadoMensajesPrivados < Accion
  def initialize
    @usuarios = {}
    @ultimo_mensaje
  end

  # Método que recibe un mensaje desde un chat privado y se encarga de dirigirlo hacia el lugar adecuado para su procesamiento
  # * *Args*    :
  #   - +mensaje+ -> nuevo mensaje recibido desde un chat grupal
  #
  def recibir_mensaje(mensaje)
    id_telegram = mensaje.usuario.id_telegram
    accion = @usuarios[id_telegram]
    if accion
      if accion[:thread].alive? == false
         @usuarios[mensaje.usuario.id_telegram][:accion]=accion[:thread].value
        @usuarios[mensaje.usuario.id_telegram][:thread]= Thread.new do @usuarios[mensaje.usuario.id_telegram][:accion].recibir_mensaje(mensaje) end
      else
        @bot.api.send_message(chat_id: mensaje.usuario.id_telegram, text: 'Acción anterior aún en proceso espere unos momentos')
      end

    else
      anadir_nuevo_usuario(mensaje)
    end
  end

  # Establece el client de Telegram utilizado para mandar mensajes
  # * *Args*    :
  #   - +bot+ -> cliente de telegram utilizado para mandar mensajes
  #
  def establecer_bot(bot)
    @bot = bot
  end

  private


  #  Devuelve el menú inicial para un usuario
  # * *Args*    :
  #   - +id_telegram+ -> identificador de Telegram del usuario al cual se le está buscando el menú inicial
  #   - +rol+ -> determina el rol que tiene el usuario identificado por id_telegram
  # * *Returns* :
  #   - +menu+ -> Tipo Menu es el menú principal que va a tener asignado el usuario


  def obtener_menu_inicio(id_telegram, rol)
    menu = nil
    usuario = UsuarioRegistrado.new(id_telegram)
    cursos = usuario.obtener_cursos_usuario
    if rol == 'estudiante'
      menu = MenuPrincipalEstudiante.new
    elsif rol == 'profesor'
      menu = MenuPrincipalProfesor.new
    end
    menu.iniciar_cambio_curso(id_telegram, cursos[0].id_curso)
    menu
  end

  #  Añade un nuevo usuario de Telegram al conjunto de usuarios que han mandado un mensaje al bot.
  # * *Args*    :
  #   - +mensaje+ -> primer mensaje que ha mandado el usuario al bot
  def anadir_nuevo_usuario(mensaje)
    @usuarios[mensaje.usuario.id_telegram] = {}
    case mensaje.usuario.tipo
    when 'estudiante'
      menu_inicio = obtener_menu_inicio(mensaje.usuario.id_telegram, 'estudiante')
      @usuarios[mensaje.usuario.id_telegram][:accion] = menu_inicio
    when 'profesor'
      menu_inicio = obtener_menu_inicio(mensaje.usuario.id_telegram, 'profesor')
      @usuarios[mensaje.usuario.id_telegram][:accion] = menu_inicio
    when 'desconocido'
      @usuarios[mensaje.usuario.id_telegram][:accion] = AccionInicializarDesconocido.new
    end
     @usuarios[mensaje.usuario.id_telegram][:thread]= Thread.new do @usuarios[mensaje.usuario.id_telegram][:accion].ejecutar(mensaje) end
    
  end

  public_class_method :new
end
