require_relative '../../lib/mensaje'
require_relative '../moodle_api'
require_relative '../moodle/usuario'
require_relative 'accion'

class AccionInicializarDesconocido < Accion
  def initialize
    @fase='inicio'
    @datos=Hash.new
    @usuario=Usuario.new
    @moodle=Moodle.new(ENV['TOKEN_BOT_MOODLE'])
  end

  def reiniciar
    @fase='inicio'
    usuario=Usuario.new
  end

  def ejecutar(id_telegram)

    if @usuario.id_telegram.nil?
      @usuario.id_telegram=id_telegram
    end
    @@bot.api.send_message( chat_id: @usuario.id_telegram, text: "Para empezar a utilizar el bot es necesario identificarse. Introduzca su email:", parse_mode: 'Markdown')
    @fase='peticion_email'
  end

  def recibir_mensaje(mensaje)
    id_telegram=mensaje.obtener_identificador_telegram
    datos_mensaje=mensaje.obtener_datos_mensaje
    siguiente_accion=self
    if @usuario.id_telegram.nil?
      @usuario.id_telegram=id_telegram
    end

    case @fase
      when 'inicio'
        ejecutar(id_telegram)
      when 'peticion_email'
        @usuario.email=datos_mensaje
        @@bot.api.send_message( chat_id: @usuario.id_telegram, text: "Introduzca su contraseña:", parse_mode: 'Markdown')
        @fase='peticion_contraseña'
      when 'peticion_contraseña'
        @usuario.contrasena=datos_mensaje
        token=Moodle.obtener_token(@usuario.email, datos_mensaje, ENV['WEBSERVICE_PROFESOR_MOODLE'])['token']
        puts token
        if token
          @usuario.rol='profesor'
        else
          token=Moodle.obtener_token(@usuario.email, datos_mensaje, ENV['WEBSERVICE_ESTUDIANTES_MOODLE'])['token']
          puts token
          if token
            @usuario.rol='estudiante'
          end
        end
        if token
          @usuario.id_moodle=@moodle.obtener_identificador_moodle(@usuario.email)
          cursos=@moodle.obtener_cursos_usuario(@usuario.id_moodle)
          @usuario.anadir_cursos_moodle(cursos)
          @usuario.token=token
          @usuario.nombre_usuario=mensaje.obtener_nombre_usuario
          dar_alta_usuario
          @@bot.api.send_message( chat_id: @usuario.id_telegram, text: "Dado de alta en el bot con exito, ya puede empezar a utilizarlo", parse_mode: 'Markdown' )
        else
          @@bot.api.send_message( chat_id: @usuario.id_telegram, text: 'Datos de login incorrectos o bien el usuario no esta autorizado a utilizar el bot', parse_mode: 'Markdown' )
        end
        reiniciar
    end


    return siguiente_accion
  end


  def dar_alta_usuario
    @@db.from(:usuario_telegram).insert(:id_telegram => @usuario.id_telegram, :nombre_usuario => @usuario.nombre_usuario )

    if @usuario.rol == 'profesor'
      @@db.from(:profesor).insert(:id_telegram => @usuario.id_telegram, :email =>@usuario.email)
      @@db.from(:profesor_moodle).insert(:email =>@usuario.email, :token => @usuario.token, :id_moodle => @usuario.id_moodle )

      cursos_ya_existentes=@@db.from(:profesor_curso).where(:id_profesor => @usuario.id_telegram).select(:id_moodle_curso).to_a
      id_cursos=cursos_ya_existentes
      @usuario.cursos.each{
          |curso|
        puts curso
        unless id_cursos.include? curso[:id_moodle]
          @@db.from(:curso).insert(:nombre_curso => curso[:nombre_curso], :id_moodle => curso[:id_moodle])
          @@db.from(:profesor_curso).insert(:id_profesor => @usuario.id_telegram, :id_moodle_curso => curso[:id_moodle])
        end
      }
    else
      @@db.from(:estudiante).insert(:id_telegram => @usuario.id_telegram, :email =>@usuario.email)
      @@db.from(:estudiante_moodle).insert(:email =>@usuario.email, :token => @usuario.token, :id_moodle => @usuario.id_moodle )
      @usuario.cursos.each{
          |curso|
        unless @@db.from(:curso).where(:id_moodle => curso[:id_moodle]).to_a.empty?
          @@db.from(:estudiante_curso).insert(:id_estudiante => @usuario.id_telegram, :id_moodle_curso => curso[:id_moodle])
        end
      }

    end
  end





  public_class_method :new
end