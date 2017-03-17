
class Accion
  @@bot=nil
  @nombre="Accion"
  def initialize
    @db=Sequel.connect(ENV['URL_DATABASE'])
  end

  def recibir_mensaje(mensaje)
    raise NotImplementedError.new
  end
  def ejecutar()
    raise NotImplementedError.new
  end



  def self.nombre
    @nombre
  end

  def self.establecer_bot bot
    @@bot=bot
  end

  private_class_method :new
end