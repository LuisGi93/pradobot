require_relative 'conexion_bd'

#Clase que simboliza un chat de telegram
class ChatTelegram < ConexionBD
  attr_reader :id_chat, :nombre
  def initialize id_chat, nombre = nil
    @id_chat = id_chat
    @nombre = nombre
  end
# Comprueba si el chat al que representa se encuentra registrado en la base de datos
  # * *Returns* :
  #   - True si lo está, false en caso contratio
  def registrado?
    cursos = @@db[:chat_curso].where(nombre_chat_telegram: @nombre).to_a
    if cursos.empty?
      return false
    else
      return true
    end
  end  
  # Registrado los datos del chat que simboliza en la base de datos
  def dar_de_alta
    @@db[:chat_telegram].where(nombre_chat: @nombre).update(id_chat: @id_chat)
  end

  # Obtiene el curso asociado al chat que simboliza 
   def obtener_curso_asociado
    datos_cursos = @@db[:chat_curso].where(nombre_chat_telegram: @nombre).select(:id_moodle_curso).first
    unless datos_cursos.empty?
      id_curso = datos_cursos[:id_moodle_curso]
      curso = Curso.new(id_curso)
      return curso
    end
  end

end

require_relative 'curso'
