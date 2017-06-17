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
    if @respuestas.nil?
      @respuestas=Array.new
      array_dataset=@@db[:respuesta_duda].where(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido).to_a
      puts array_dataset.to_s
      array_dataset.each{|dataset_respuesta|
        @respuestas << Respuesta.new(dataset_respuesta[:contenido_respuesta], Usuario.new(dataset_respuesta[:id_usuario_respuesta]), self)
      }
    end
    return @respuestas
  end

  def insertar_solucion respuesta
    @@db[:dudas_resueltas].insert(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido)
    @@db[:respuesta_resuelve_duda].insert(:id_usuario_respuesta => respuesta.usuario.id_telegram, :contenido_respuesta => respuesta.contenido, :id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido)
  end

  def solucion
    datos_respuesta=@@db[:respuesta_resuelve_duda].where(:id_usuario_duda => @usuario.id_telegram, :contenido_duda => @contenido).to_a
    puts @usuario.id_telegram
    puts @contenido
    puts datos_respuesta.to_s
    if datos_respuesta.empty?
      respuesta=nil
    else
      respuesta=Respuesta.new(datos_respuesta[0][:contenido_respuesta], Usuario.new(datos_respuesta.first[:id_usuario_respuesta]), Duda.new(@contenido, @usuario) )
    end
    return respuesta
  end

  def == (y)
    puts @contenido
    puts y.contenido
    puts @usuario.id_telegram
    puts y.usuario.id_telegram
    return @contenido == y.contenido && @usuario.id_telegram == y.usuario.id_telegram
  end
end

require_relative 'usuario'
