class Peticion
  attr_reader :tutoria, :estudiante
  attr_accessor :hora
  def initialize tutoria, estudiante, hora=nil
    @tutoria=tutoria
    @estudiante=estudiante
    @hora=hora
  end
end