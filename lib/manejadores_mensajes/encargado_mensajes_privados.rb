require_relative '../actuadores_sobre_mensajes/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/actuadores_sobre_mensajes/accion'
require_relative '../../lib/contenedores_datos/usuario_desconocido'
require_relative '../../lib/actuadores_sobre_mensajes/acciones_profesor/menu_principal_profesor'
require_relative '../../lib/actuadores_sobre_mensajes/accion_inicializar_desconocido'
require_relative '../../lib/contenedores_datos/usuario'
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
    @usuarios=Hash.new
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    accion=@usuarios[id_telegram]
    if accion
      #debug #estado=accion[:thread].status
      if true#debug  #estado == false || estado.nil?
        #@usuarios[id_telegram][:accion]=accion[:thread].value
        #@usuarios[id_telegram][:thread]= Thread.new do @usuarios[id_telegram][:accion].recibir_mensaje(mensaje) end
        @usuarios[id_telegram][:thread]=  @usuarios[id_telegram][:thread].recibir_mensaje(mensaje)
      else
        @bot.api.send_message( chat_id: id_telegram, text: "Acción anterior aún en proceso espere unos momentos")
      end

    else
      anadir_nuevo_usuario(id_telegram)
    end
  end

  def establecer_bot bot
    @bot=bot
  end

  private

  def obtener_menu_inicio id_telegram, rol
    menu=nil
    usuario=Usuario.new(id_telegram)
    cursos=usuario.obtener_cursos_usuario
    if rol =='estudiante'
      menu=MenuPrincipalEstudiante.new
    elsif rol =='profesor'
      menu=MenuPrincipalProfesor.new
    end
    menu.iniciar_cambio_curso(id_telegram,cursos[0].id_curso)
    return menu
  end

  def anadir_nuevo_usuario id_telegram
    usuario_desconocido=UsuarioDesconocido.new(id_telegram)
    tipo_usuario=usuario_desconocido.que_tipo_usuario_soy
    @usuarios[id_telegram]=Hash.new
    puts tipo_usuario
    case tipo_usuario
      when 'estudiante'
        menu_inicio=obtener_menu_inicio(id_telegram, 'estudiante')
        @usuarios[id_telegram][:accion]=menu_inicio
      when 'profesor'
        menu_inicio=obtener_menu_inicio(id_telegram, 'profesor')
        @usuarios[id_telegram][:accion]=menu_inicio
      when 'admin'
        #todo
      when 'desconocido'
        @usuarios[id_telegram][:accion]=AccionInicializarDesconocido.new
    end
    #@usuarios[id_telegram][:thread]= Thread.new do @usuarios[id_telegram][:accion].ejecutar(id_telegram) end
    @usuarios[id_telegram][:thread]=  @usuarios[id_telegram][:accion].ejecutar(id_telegram) #debug mode si peta en un thread no me entero
  end



  public_class_method :new

end