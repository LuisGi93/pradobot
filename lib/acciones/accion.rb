
class Accion
  @@bot=nil
  @nombre="Accion"
  def initialize
    @acciones=Hash.new
    @db=Sequel.connect(ENV['URL_DATABASE'])
  end

  def ejecutar(mensaje)
    raise NotImplementedError.new
  end

  def atras
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