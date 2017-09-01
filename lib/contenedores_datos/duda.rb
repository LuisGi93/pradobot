require_relative 'conexion_bd'

#Clase que simboliza una duda de un curso
class Duda < ConexionBD
  attr_reader :contenido, :usuario
  def initialize(contenido_duda, usuario)
    @contenido = contenido_duda
    @usuario = usuario
    @respuestas = nil
  end

 # Añade una nueva respueta a la duda 
  #
  #   # * *Args*    :
  #   - +respuesta+ -> Nueva respuesta 
  def nueva_respuesta(respuesta)
    @@db[:respuestas].insert(id_usuario_respuesta: respuesta.usuario.id_telegram, contenido_respuesta: respuesta.contenido)
    @@db[:respuesta_duda].insert(id_usuario_respuesta: respuesta.usuario.id_telegram, contenido_respuesta: respuesta.contenido, id_usuario_duda: @usuario.id_telegram, contenido_duda: @contenido)
  end

 # Devuelve las respuesta de la duda 
  #
  # * *Returns* :
  #   - Devuelve un array con todas las respuesta que ha tenido la duda  #
  def respuestas
    @respuestas = []
    array_dataset = @@db[:respuesta_duda].where(id_usuario_duda: @usuario.id_telegram, contenido_duda: @contenido).to_a
    array_dataset.each do |dataset_respuesta|
      @respuestas << Respuesta.new(dataset_respuesta[:contenido_respuesta], UsuarioRegistrado.new(dataset_respuesta[:id_usuario_respuesta]), self)
    end
    @respuestas
  end



 # Añade una nueva respueta a la duda 
  #
  #   # * *Args*    :
  #   - +respuesta+ -> Nueva respuesta 
  def insertar_solucion(respuesta)
    @@db[:dudas_resueltas].insert(id_usuario_duda: @usuario.id_telegram, contenido_duda: @contenido)
    @@db[:respuesta_resuelve_duda].insert(id_usuario_respuesta: respuesta.usuario.id_telegram, contenido_respuesta: respuesta.contenido, id_usuario_duda: @usuario.id_telegram, contenido_duda: @contenido)
  end

  #Devuelve la Respuesta que es solución de la duda 
  #
  # * *Returns* :
  #   - Devuelve la Respuesta que soluciona la duda 
  def solucion
    datos_respuesta = @@db[:respuesta_resuelve_duda].where(id_usuario_duda: @usuario.id_telegram, contenido_duda: @contenido).to_a
    if datos_respuesta.empty?
      respuesta = nil
    else
      respuesta = Respuesta.new(datos_respuesta[0][:contenido_respuesta], UsuarioRegistrado.new(datos_respuesta.first[:id_usuario_respuesta]), Duda.new(@contenido, @usuario))
    end
    respuesta
  end

  def ==(y)
    @contenido == y.contenido && @usuario.id_telegram == y.usuario.id_telegram
  end
end

require_relative 'usuario_registrado'
