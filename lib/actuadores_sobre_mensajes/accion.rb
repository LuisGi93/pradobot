require_relative '../contenedores_datos/mensaje'

#
# Clase abstracta que recibe un mensaje y lleva a cabo una acción de acuerdo con el contenido del mensaje.
#
class Accion
  @@bot=nil
  @nombre="Accion"
  @curso=nil



  #
  # Lleva a cabo una acción en funciòn del contenido del mensaje.
  # * *Args*    :
  #   - +mensaje+ -> mensaje del bot de telegram destinado a esta acciòn
  # * *Returns* :
  #   - Devuelve la siguiente acción que se ejecutará como respuesta
  #
  def recibir_mensaje(mensaje)
    raise NotImplementedError.new
  end


  #
  # Establece el nombre descriptivo de la acción que se muestra en los tecládos gráficos de Telegram.
  #
  def self.nombre
    @nombre
  end

  #
  # Establece el bot de Telegram que utilizarán toda aquella acción para comunicarse con los usuarios.
  #
  def self.establecer_bot bot
    @@bot=bot
  end





  private_class_method :new
  protected
    attr_accessor :curso
end
