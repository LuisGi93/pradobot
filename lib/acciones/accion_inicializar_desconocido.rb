

class AccionInicializarDesconocido < Accion
  def initialize
    @fase='inicio'
    @usuario_desconocido=UsuarioDesconocido.new
    @moodle=Moodle.new(ENV['TOKEN_BOT_MOODLE'])
  end

  def reiniciar
    @fase='inicio'
    usuario=Usuario.new
  end

  def ejecutar(id_telegram)

    if @usuario_desconocido.id_telegram.nil?
      @usuario_desconocido.id_telegram=id_telegram
    end
    @@bot.api.send_message( chat_id: @usuario_desconocido.id_telegram, text: "Para empezar a utilizar el bot es necesario identificarse. Introduzca su email:", parse_mode: 'Markdown')
    @fase='peticion_email'
    return self
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=self
    if @usuario_desconocido.id_telegram.nil?
      @usuario_desconocido.id_telegram=id_telegram
    end

    case @fase
      when 'inicio'
        ejecutar(id_telegram)
      when 'peticion_email'
        @usuario_desconocido.email=datos_mensaje
        @@bot.api.send_message( chat_id: @usuario_desconocido.id_telegram, text: "Introduzca su contraseña:", parse_mode: 'Markdown')
        @fase='peticion_contraseña'
      when 'peticion_contraseña'
        @usuario_desconocido.contrasena=datos_mensaje
        token=Moodle.obtener_token(@usuario_desconocido.email, datos_mensaje, ENV['WEBSERVICE_PROFESOR_MOODLE'])['token']
        puts token
        if token
          @usuario_desconocido.rol='profesor'
        else
          token=Moodle.obtener_token(@usuario_desconocido.email, datos_mensaje, ENV['WEBSERVICE_ESTUDIANTES_MOODLE'])['token']
          puts token
          if token
            @usuario_desconocido.rol='estudiante'
          end
        end
        if token
          @usuario_desconocido.id_moodle=@moodle.obtener_identificador_moodle(@usuario_desconocido.email)
          cursos=@moodle.obtener_cursos_usuario(@usuario_desconocido.id_moodle)
          @usuario_desconocido.anadir_cursos_moodle(cursos)
          @usuario_desconocido.token=token
          @usuario_desconocido.nombre_usuario=mensaje.obtener_nombre_usuario
          @usuario_desconocido.registrarme_en_el_sistema
          @@bot.api.send_message( chat_id: @usuario_desconocido.id_telegram, text: "Dado de alta en el bot con exito, ya puede empezar a utilizarlo", parse_mode: 'Markdown' )
          if @usuario_desconocido.rol == "profesor"
            siguiente_accion=AccionElegirCurso.new(MenuPrincipalProfesor.new)
          elsif @usuario_desconocido.rol == "estudiante"
            siguiente_accion=AccionElegirCurso.new(MenuPrincipalEstudiante.new)
          end
        else
          @@bot.api.send_message( chat_id: @usuario_desconocido.id_telegram, text: 'Datos de login incorrectos o bien el usuario no esta autorizado a utilizar el bot', parse_mode: 'Markdown' )
        end
        reiniciar
    end


    return siguiente_accion
  end






  public_class_method :new
end

require_relative '../../lib/mensaje'
require_relative '../moodle_api'
require_relative '../usuarios/usuario_desconocido'
require_relative 'accion'
require_relative '../../lib/acciones/acciones_estudiante/menu_principal_estudiante'
require_relative '../../lib/acciones/acciones_profesor/menu_principal_profesor'
require_relative '../acciones/accion_elegir_curso'