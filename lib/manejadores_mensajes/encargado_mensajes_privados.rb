require_relative '../actuadores_sobre_mensajes/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/actuadores_sobre_mensajes/accion'
require_relative '../../lib/contenedores_datos/usuario_desconocido'
require_relative '../../lib/actuadores_sobre_mensajes/acciones_profesor/menu_principal_profesor'
require_relative '../../lib/actuadores_sobre_mensajes/accion_inicializar_desconocido'
require_relative '../../lib/contenedores_datos/usuario_registrado'
#
#
# * *Args*    :
#   - ++ ->
# * *Returns* :
#   -
# * *Raises* :
#   - ++ ->
#
class EncargadoMensajesPrivados < Accion
  def initialize
    @usuarios = {}
    @ultimo_mensaje
  end

  def recibir_mensaje(mensaje)
    id_telegram = mensaje.usuario.id_telegram
    accion = @usuarios[id_telegram]
    if accion
      # debug #estado=accion[:thread].status
      if true # debug  #estado == false || estado.nil?
        # @usuarios[mensaje.usuario.id_telegra][:accion]=accion[:thread].value
        # @usuarios[mensaje.usuario.id_telegram][:thread]= Thread.new do @usuarios[@ultimo_mensaje.usuario.id_telegram][:accion].recibir_mensaje(mensaje) end
        @usuarios[mensaje.usuario.id_telegram][:thread] = @usuarios[mensaje.usuario.id_telegram][:thread].recibir_mensaje(mensaje)
      else
        @bot.api.send_message(chat_id: mensaje.usuario.id_telegram, text: 'Acción anterior aún en proceso espere unos momentos')
      end

    else
      anadir_nuevo_usuario(mensaje)
    end
  end

  def establecer_bot(bot)
    @bot = bot
  end

  private

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
    # @usuarios[mensaje.usuario.id_telegram][:thread]= Thread.new do @usuarios[mensaje.usuario.id_telegram][:accion].ejecutar(mensaje) end
    #
    @usuarios[mensaje.usuario.id_telegram][:thread] = @usuarios[mensaje.usuario.id_telegram][:accion].ejecutar(mensaje) # debug mode si peta en un thread no me entero
  end

  public_class_method :new
end
