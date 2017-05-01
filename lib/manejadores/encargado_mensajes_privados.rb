require_relative '../acciones/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/acciones/accion'
require_relative '../../lib/usuarios/usuario_desconocido'
require_relative '../acciones/accion_elegir_curso'
require_relative '../../lib/acciones/acciones_profesor/menu_principal_profesor'

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

  def anadir_nuevo_usuario id_telegram
    usuario_desconocido=UsuarioDesconocido.new(id_telegram)
    tipo_usuario=usuario_desconocido.que_tipo_usuario_soy
    @usuarios[id_telegram]=Hash.new
    case tipo_usuario
      when 'estudiante'
        puts "EStudiante"
        @usuarios[id_telegram][:accion]=AccionElegirCurso.new(MenuPrincipalEstudiante.new)
      when 'profesor'
        @usuarios[id_telegram][:accion]=AccionElegirCurso.new(MenuPrincipalProfesor.new)
      when 'admin'
        #todo
      when 'desconocido'
        @usuarios[id_telegram][:accion]=AccionInicializarDesconocido.new
    end
    #@usuarios[id_telegram][:thread]= Thread.new do @usuarios[id_telegram][:accion].ejecutar(id_telegram) end
    @usuarios[id_telegram][:thread]=  @usuarios[id_telegram][:accion].ejecutar(id_telegram) #debug mode si peta en un thread no me entero
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    accion=@usuarios[id_telegram]
    if accion
      #debug #estado=accion[:thread].status
      if true#debug  #estado == false || estado.nil?
        #@usuarios[id_telegram][:accion]=accion[:thread].value
        #@usuarios[id_telegram][:thread]= Thread.new do @usuarios[id_telegram][:accion].recibir_mensaje(mensaje) end
        puts @usuarios[id_telegram][:thread]
        puts @usuarios[id_telegram][:thread].class
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

  public_class_method :new

end