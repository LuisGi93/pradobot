require_relative 'accion'
require 'telegram/bot'


class Menu < Accion
  attr_reader :tipo

  @acciones=nil
  def initialize
    @accion_pulsada=nil
    @rol_usuario_acciones=nil
  end

  def inicializar_acciones token_usuario
    raise NotImplementedError.new
  end

  def cambiar_curso(nombre_curso, id_curso)
    raise NotImplementedError.new
  end


  def obtener_cursos_usuario id_telegram
    id_cursos_usuario=@@db[:estudiante_curso].where(:id_estudiante => id_telegram).select(:id_moodle_curso).to_a
    if id_cursos_usuario.empty?
      id_cursos_usuario=@@db[:profesor_curso].where(:id_profesor => id_telegram).select(:id_moodle_curso).to_a
    end
    return id_cursos_usuario
  end

  def introduce_nuevo_curso id_telegram
    kb = Array.new
    id_cursos_usuario=obtener_cursos_usuario(id_telegram)
    unless id_cursos_usuario.empty?
      cursos=Array.new
      id_cursos_usuario.each{|id_curso|
        cursos << @@db[:curso].where(:id_moodle => id_curso[:id_moodle_curso]).first
      }
      puts cursos.to_s
      cursos.each{|curso|
        puts curso.to_s
        nombre_curso=curso[:nombre_curso]
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: nombre_curso, callback_data: "cambiando_a_curso_id_curso##{curso[:id_moodle]}#nombre_curso##{nombre_curso}")
      }
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Todos cursos", callback_data: "cambiando_a_curso_id_curso#-99#nombre_curso#Todos cursos")

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      @@bot.api.send_message( chat_id: id_telegram, text: 'Elija curso:', reply_markup: markup)
    end

  end

  def cambiar_curso_pulsado mensaje
    pulsado=false
    datos_mensaje=mensaje.obtener_datos_mensaje
    if datos_mensaje  =~ /Cambiar curso. Curso actual:.+/
      introduce_nuevo_curso mensaje.obtener_identificador_telegram
      pulsado=true
    elsif datos_mensaje  =~ /cambiando_a_curso_id_curso#.+/
      datos_mensaje.slice! "cambiando_a_curso_id_curso#"
      id_moodle = datos_mensaje[/^[0-9]{1,2}/]
      puts "El ide de moodle es #{id_moodle}"
      puts datos_mensaje
      datos_mensaje.slice! "#{id_moodle}#nombre_curso#"
      puts datos_mensaje
      cambiar_curso(datos_mensaje, id_moodle)
      pulsado=true
      @@bot.api.answer_callback_query(:callback_query_id => mensaje.obtener_identificador_mensaje, text:"curso_cambiado")
      ejecutar(mensaje.obtener_identificador_telegram)

    end

    return pulsado
  end

  def ejecutar(id_telegram)
    kb= Array.new
    @acciones.keys.each{
        |accion|
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
    }
    iniciar_acciones_defecto(kb)

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
    @@bot.api.send_message( chat_id: id_telegram, text: "Elija entre las acciones del menu",  reply_markup: markup)
    return self
  end

  def accion_pulsada id_telegram,datos_mensaje
    raise NotImplementedError.new
  end

  def obtener_siguiente_accion(id_telegram, datos_mensaje)
    raise NotImplementedError.new
  end


  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso['nombre_curso']}", )
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras", )
  end


  public_class_method :new
  private :inicializar_acciones

end