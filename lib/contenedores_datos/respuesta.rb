require_relative 'conexion_bd'

class Respuesta
  attr_reader :contenido, :usuario, :duda
  def initialize(contenido, usuario, duda)
    @contenido = contenido
    @usuario = usuario
    @duda = duda
  end

  def ==(y)
    @contenido == y.contenido && @usuario.id_telegram == y.usuario.id_telegram && @duda == y.duda
  end
end

require_relative 'usuario'
require_relative 'duda'
