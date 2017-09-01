require_relative 'conexion_bd'

class Usuario < ConexionBD
  attr_reader :id_telegram, :nombre_usuario, :tipo

  def initialize(id_telegram, nombre_usuario)
    @id_telegram = id_telegram
    @nombre_usuario = nombre_usuario
    establecer_tipo_usuario
  end

  def establecer_tipo_usuario
    if @tipo_usuario.nil?
      usuario = @@db[:usuario_telegram].where(id_telegram: @id_telegram).first
      @tipo = 'desconocido'
      if usuario
        es_profesor = @@db[:profesor].where(id_telegram: @id_telegram).first
        if es_profesor
          @tipo = 'profesor'
        else
          es_estudiante = @@db[:estudiante].where(id_telegram: @id_telegram).first
          @tipo = 'estudiante' if es_estudiante
        end
      end
    end
  end
end
