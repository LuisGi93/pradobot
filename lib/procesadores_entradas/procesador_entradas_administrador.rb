class ProcesadorEntradasAdministrador


  def quiere_dar_alta_profesor(mensaje, estado)

    tipo_mensaje=mensaje.class

    if (tipo_mensaje == Telegram::Bot::Types::CallbackQuery && mensaje.data == "alta_profesor")
        return true
    end

    if estado && estado["alta_profesor"]
      return true
    end
=begin
    if estado!=nil
    unless  estado["alta_profesor"].nil?
      return true
    end
end
=end

  end
end