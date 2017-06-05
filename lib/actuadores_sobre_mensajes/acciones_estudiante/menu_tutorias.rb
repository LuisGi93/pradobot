require_relative  'solicitar_tutoria'
require_relative 'ver_peticiones_tutorias'
require_relative '../menu_acciones'


class MenuTutorias < MenuDeAcciones
  @nombre= 'Tutorías'
  def initialize accion_padre
    @accion_padre=accion_padre
    @acciones=Hash.new
    inicializar_acciones
  end


  def inicializar_acciones
    @acciones[SolicitarTutoria.nombre] = SolicitarTutoria.new
    @acciones[VerPeticionesTutoria.nombre] = VerPeticionesTutoria.new

  end

  def iniciar_acciones_defecto kb
    kb <<   Telegram::Bot::Types::KeyboardButton.new( text: "Atras")
  end
  private :inicializar_acciones

end