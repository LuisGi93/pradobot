require_relative 'accion'
require_relative '../../lib/contenedores_datos/usuario'

#
# Agrupa todas la funcionalidad común necesaria para poder mostrar un menú gráfico (https://core.telegram.org/bots/api#replykeyboardmarkup) con diferentes opciones.
#
class Menu < Accion

  private
  def inicializar_acciones
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

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: fila_botones)

      @@bot.api.send_message( chat_id: id_telegram, text: 'Elija curso:', reply_markup: markup)
    end

  end

  #
  # Comprueba si el mensaje recibido indica que el usuario quiere que las actuadores_sobre_mensajes se lleven a cabo sobre un curso diferente en cuyo
  # caso realiza lo necesario para que el arbol de actuadores_sobre_mensajes asociado al usuario actue sobre un curso diferente.
  # * *Args*    :
  #   - +mensaje+ -> mensaje cuyo contenido determinada si el usuario quiere cambiar el curso sobre el que se aplican las actuadores_sobre_mensajes.
  # * *Returns* :
  #   - true si el contenido del mensaje indica que el usuario quiere cambiar curso false en caso contrario

  def cambiar_curso_pulsado mensaje
    pulsado=false
    datos_mensaje=mensaje.obtener_datos_mensaje
    if datos_mensaje  =~ /Cambiar de curso.+/
      solicitar_introducir_nuevo_curso mensaje.obtener_identificador_telegram
      pulsado=true
    elsif datos_mensaje  =~ /cambiando_a_curso_id_curso#.+/
      datos_mensaje.slice! "cambiando_a_curso_id_curso#"
      id_curso = datos_mensaje[/^[0-9]{1,2}/]
      id_curso=id_curso.to_i
      iniciar_cambio_curso(mensaje.obtener_identificador_telegram, id_curso)
      pulsado=true
      @@bot.api.answer_callback_query(:callback_query_id => mensaje.id_callback, text:"Cambiando de curso..")
      ejecutar(mensaje.obtener_identificador_telegram)

    end

    return pulsado
  end

  #
  # Añade las actuadores_sobre_mensajes comunes a todos los menús al conjunto de actuadores_sobre_mensajes que le muestra un menú al usuario
  # * *Args*    :
  #   - +kb+ -> Téclado en el cual se muestra gráficamente las actuadores_sobre_mensajes que contiene el menú

  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar curso. Curso actual: #{@curso.nombre}.")
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras", )
  end


  public


  #
  # Cambia el curso sobre el cual actúan las actuadores_sobre_mensajes/menús contenidos en este menú.
  # * *Args*    :
  #   - +cursos+ -> Contiene el nuevo curso o cursos sobre el que actuarán las actuadores_sobre_mensajes contenidas en el menú.

  def cambiar_curso_parientes
    raise NotImplementedError.new
  end

  #
  # Cambia el curso sobre el cual actúa el menú.
  # * *Args*    :
  #   - +cursos+ -> Contiene el nuevo curso o cursos sobre el cual actuará el menú.

  def cambiar_curso(curso)
    @curso=curso
    cambiar_curso_parientes
  end


  #
  # Inicia el cambio de curso para toda la jerarquía de actuadores_sobre_mensajes.
  # * *Args*    :
  #   - +id_telegram+ -> Identifica al usuario que desea cambiar de curso
  #   - +id_curso+ -> Identifica al curso al cual desea cambiar el usuario identificado por +id_telegram+

  def iniciar_cambio_curso(id_telegram, id_curso)
      usuario=Usuario.new(id_telegram)
      cursos=usuario.obtener_cursos_usuario
      @curso=nil
      cont=0
      while(@curso.nil? && cont < cursos.size)
        if cursos[cont].id_curso==id_curso
          @curso = cursos[cont]
          cont=cursos.size
        end
        cont+=1

      end

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
    @@bot.api.send_message( chat_id: id_telegram, text: "Elija entre las opciones del menu",  reply_markup: markup)
    return self
  end


  #
  # Añade las actuadores_sobre_mensajes comunes a todos los menús al conjunto de actuadores_sobre_mensajes que le muestra un menú al usuario
  # * *Args*    :
  #   - +kb+ -> Téclado en el cual se muestra gráficamente las actuadores_sobre_mensajes que contiene el menú

  def iniciar_acciones_defecto kb
    aux=Array.new
    aux <<   Telegram::Bot::Types::KeyboardButton.new( text: "Cambiar de curso (#{@curso.nombre}).")
    aux <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras", )
    kb << aux
  end


  public_class_method :new
  private :inicializar_acciones

end
