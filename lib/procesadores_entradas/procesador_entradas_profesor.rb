class ProcesadorEntradasProfesor

  def test(mensaje, estado)

    tipo_mensaje=mensaje.class

    if (tipo_mensaje == Telegram::Bot::Types::Message && mensaje.data == "/start")
      return true

    end

  end

  def inicializar_profesor(mensaje, estado)

    return true

  end
end