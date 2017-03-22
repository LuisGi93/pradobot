require 'sequel'

class Accion
  @@bot=nil
  @@db=nil
  @nombre="Accion"
  @curso=nil



  def ejecutar(id_telegram)
    raise NotImplementedError.new
  end

  def introduce_nuevo_grupo id_telegram
    kb = Array.new
    cursos=@@db[:cursos].where(:id_telegram_profesor_responsable => id_telegram).to_a

    if cursos
      cursos.each{|curso|
        nombre_curso=curso[:nombre_curso]
        id_curso="Cambiar a curso "+curso[:nombre_curso]
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: nombre_curso, callback_data: "cambiando_a_curso_#{nombre_curso}")
      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      @@bot.api.send_message( chat_id: id_telegram, text: 'Elija curso:', reply_markup: markup)
    end

  end

  def cambiar_curso_pulsado id_telegram, datos_mensaje
    pulsado=false
    if datos_mensaje  =~ /Cambiar curso. Curso actual:/
      introduce_nuevo_grupo id_telegram
      pulsado=true
    elsif datos_mensaje  =~ /cambiando_a_curso_.+/
      datos_mensaje.slice! "cambiando_a_curso_"
      cambiar_curso(datos_mensaje)
      pulsado=true
    end
    if pulsado
      ejecutar(id_telegram)
    end
    return pulsado
  end


  def self.nombre
    @nombre
  end

  def self.establecer_bot bot
    @@bot=bot
  end

  def self.establecer_db db
    @@db=db
  end




  private_class_method :new
  protected
    attr_accessor :curso
end