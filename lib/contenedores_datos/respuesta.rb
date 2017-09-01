require_relative 'conexion_bd'

#Simboliza una respuesta a una duda
class Respuesta
  attr_reader :contenido, :usuario, :duda
  def initialize(contenido, usuario, duda)
    @contenido = contenido
    @usuario = usuario
    @duda = duda
  end

  # Comprueba si dos respuetas son iguales
  #  *Returns* :
      #   - True si lo son, false en caso contrario
  def ==(y)
    @contenido == y.contenido && @usuario.id_telegram == y.usuario.id_telegram && @duda == y.duda
  end
end

require_relative 'usuario'
require_relative 'duda'
