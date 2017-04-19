require 'sequel'
require_relative '../mensaje'

class Accion
  @@bot=nil
  @@db=nil
  @nombre="Accion"
  @curso=nil

def initialize
  @curso=Hash.new
end

  def ejecutar(id_telegram)
    raise NotImplementedError.new
  end

  def recibir_mensaje(mensaje)
    raise NotImplementedError.new
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