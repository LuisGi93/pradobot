
require_relative '../accion'
require_relative '../../moodle_api'

class AccionProfesor < Accion

  @@moodle=ENV['TOKEN_PROFESOR_MOODLE']
  public_class_method :new
end