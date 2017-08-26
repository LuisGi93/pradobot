require_relative 'conexion_bd'

class Duda < ConexionBD
  attr_reader :contenido, :usuario
  def initialize contenido_duda, usuario
    @contenido=contenido_duda
    @usuario=usuario
    @respuestas=nil
  end

  def nueva_respuesta respuesta
    @@db[:respuestas].insert(:id_usuario_respuesta => respuesta.usuario.id_telegram, :contenido_respuesta => respuesta.contenido)
    @@db[:respuesta_duda].insert(:id_usuario_respuesta => respuesta.usuario.id_telegram, :contenido_respuesta => respuesta.contenido, :id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido)
  end

  def respuestas
      @respuestas=Array.new
      array_dataset=@@db[:respuesta_duda].where(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido).to_a
      array_dataset.each{|dataset_respuesta|
        @respuestas << Respuesta.new(dataset_respuesta[:contenido_respuesta], UsuarioRegistrado.new(dataset_respuesta[:id_usuario_respuesta]), self)
      }
    return @respuestas
  end

  def insertar_solucion respuesta
    @@db[:dudas_resueltas].insert(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido)
    @@db[:respuesta_resuelve_duda].insert(:id_usuario_respuesta => respuesta.usuario.id_telegram, :contenido_respuesta => respuesta.contenido, :id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido)
  end

  def solucion
    datos_respuesta=@@db[:respuesta_resuelve_duda].where(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido).to_a
    if datos_respuesta.empty?
      respuesta=nil
    else
      respuesta=Respuesta.new(datos_respuesta[0][:contenido_respuesta], UsuarioRegistrado.new(datos_respuesta.first[:id_usuario_respuesta]), Duda.new(@contenido, @usuario) )
    end
    return respuesta
  end

  def == (y)
    return @contenido == y.contenido && @usuario.id_telegram == y.usuario.id_telegram
  end
end

require_relative 'usuario_registrado'
