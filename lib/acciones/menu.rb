require_relative 'accion'
require_relative '../../lib/usuarios/usuario'
require 'telegram/bot'


#
# Simboliza un teclado de respuesta de Telegram: https://core.telegram.org/bots/api#replykeyboardmarkup
# Agrupa todos aquellos métodos de los distintos teclados que usa la aplicación.
#
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


  #
  # Manda al usuario  identificado por +id_telegram+ un mensaje para que elija un curso entre los que cursa.
  # * *Args*    :
  #   - +id_telegram+ -> identificador del usuario de telegram al cual se le va a enviar el mensaje.

  def solicitar_introducir_nuevo_curso id_telegram
    kb = Array.new
    fila_botones=Array.new
    array_botones=Array.new
    contador=0

    usuario=Usuario.new(id_telegram)
    cursos=usuario.obtener_cursos_usuario
    unless cursos.empty?

      cursos.each{|curso|
        array_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: curso.nombre, callback_data: "cambiando_a_curso_id_curso##{curso.id_curso}")
        if array_botones.size == 2
          fila_botones << array_botones.dup
          array_botones.clear
        end
        contador+=1

      }

      fila_botones << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Todos cursos", callback_data: "cambiando_a_curso_id_curso#-99")

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)

      @@bot.api.send_message( chat_id: id_telegram, text: 'Elija curso:', reply_markup: markup)
    end

  end

  #
  # Comprueba si el mensaje recibido indica que el usuario quiere que las acciones se lleven a cabo sobre un curso diferente en cuyo
  # caso realiza lo necesario para que el arbol de acciones asociado al usuario actue sobre un curso diferente.
  # * *Args*    :
  #   - +mensaje+ -> mensaje cuyo contenido determinada si el usuario quiere cambiar el curso sobre el que se aplican las acciones.
  # * *Returns* :
  #   - true si el contenido del mensaje indica que el usuario quiere cambiar curso false en caso contrario

  def cambiar_curso_pulsado mensaje
    pulsado=false
    datos_mensaje=mensaje.obtener_datos_mensaje
    if datos_mensaje  =~ /Cambiar curso. Curso actual:.+/
      solicitar_introducir_nuevo_curso mensaje.obtener_identificador_telegram
      pulsado=true
    elsif datos_mensaje  =~ /cambiando_a_curso_id_curso#.+/
      datos_mensaje.slice! "cambiando_a_curso_id_curso#"
      id_curso = datos_mensaje[/^-?[0-9]{1,2}/]
      id_curso=id_curso.to_i
      iniciar_cambio_curso(mensaje.obtener_identificador_telegram, id_curso)
      pulsado=true
      @@bot.api.answer_callback_query(:callback_query_id => mensaje.obtener_identificador_mensaje, text:"curso_cambiado")
      ejecutar(mensaje.obtener_identificador_telegram)

    end

    return pulsado
  end



  #
  # Cambia el curso sobre el cual actúan las acciones/menús contenidos en este menú.
  # * *Args*    :
  #   - +cursos+ -> Contiene el nuevo curso o cursos sobre el que actuarán las acciones contenidas en el menú.

  def cambiar_curso_parientes
    raise NotImplementedError.new
  end

  #
  # Cambia el curso sobre el cual actúa el menú.
  # * *Args*    :
  #   - +cursos+ -> Contiene el nuevo curso o cursos sobre el cual actuará el menú.

  def cambiar_curso(cursos)
    @curso=cursos
    cambiar_curso_parientes
  end


  #
  # Inicia el cambio de curso para toda la jerarquía de acciones.
  # * *Args*    :
  #   - +id_telegram+ -> Identifica al usuario que desea cambiar de curso
  #   - +id_curso+ -> Identifica al curso al cual desea cambiar el usuario identificado por +id_telegram+

  def iniciar_cambio_curso(id_telegram, id_curso)
    usuario=Usuario.new(id_telegram)
    if id_curso == -99
      @curso=usuario.obtener_cursos_usuario
    else
      cursos=usuario.obtener_cursos_usuario
      @curso=nil
      cont=0
      while(@curso.nil? && cont < cursos.size)
        if cursos[cont].id_curso==id_curso
          puts "Entro aqui"
          @curso=Array.new
          @curso << cursos[cont]
          cont=cursos.size
        end
        cont+=1
        puts "Los cursos del usuario son #{@curso.to_s}"

      end
    end
    puts "Los cursos del usuario son #{@curso.to_s}"
    cambiar_curso_parientes
  end


  #
  # Implementa el método con el mismo nombre de link:Accion.html
  #

  def ejecutar(id_telegram)
    kb= Array.new
    fila_botones=Array.new
    array_botones=Array.new
    @acciones.keys.each{
        |accion|
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: accion, )
      array_botones << Telegram::Bot::Types::KeyboardButton.new( text: accion, )
      if array_botones.size == 3
        fila_botones << array_botones.dup
        array_botones.clear
      end
    }
    fila_botones << array_botones

    iniciar_acciones_defecto(fila_botones)

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: fila_botones)
    @@bot.api.send_message( chat_id: id_telegram, text: "Elija entre las acciones del menu",  reply_markup: markup)
    return self
  end

  def accion_pulsada id_telegram,datos_mensaje
    raise NotImplementedError.new
  end

  def obtener_siguiente_accion(id_telegram, datos_mensaje)
    raise NotImplementedError.new
  end


  #
  # Añade las acciones comunes a todos los menús al conjunto de acciones que le muestra un menú al usuario
  # * *Args*    :
  #   - +kb+ -> Téclado en el cual se muestra gráficamente las acciones que contiene el menú

  def iniciar_acciones_defecto kb
    if @curso.size < 2
     kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso[0].nombre}.")
    else
      kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: todos cursos.")
    end

    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras", )
  end


  public_class_method :new
  private :inicializar_acciones

end