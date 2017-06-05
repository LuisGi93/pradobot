require_relative 'conexion_bd'


class Respuesta
  attr_reader :contenido, :usuario
  def initialize contenido, usuario, duda
    @contenido=contenido
    @usuario=usuario
    @duda=duda
  end


end

require_relative 'usuario'
require_relative 'duda'
