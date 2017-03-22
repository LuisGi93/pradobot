
require_relative '../accion'
require_relative '../../moodle_api'

class AccionProfesor < Accion

  @@moodle=ENV['TOKEN_PROFESOR_MOODLE']
  attr_reader :tipo
  public_class_method :new
end