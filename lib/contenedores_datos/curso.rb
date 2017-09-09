require_relative 'conexion_bd'
require 'active_support/inflector'
require_relative '../moodle_api'

# Clase que simboliza un curso 
class Curso < ConexionBD
  attr_reader :id_curso, :nombre, :entregas

  @@moodle = Moodle.new(ENV['TOKEN_BOT_MOODLE'])

  def initialize id_curso, nombre_curso = nil
    @id_curso = id_curso.to_i
    @nombre = nombre_curso
    @profesor = nil
    @entregas = nil
  end

  #Obtiene al profesor responsable del curso
  # * *Returns* :
  #   - Devuelve Profesor responsable del curso
  def obtener_profesor_curso
    if @profesor.nil?
      consulta_db = @@db[:profesor_curso].where(id_moodle_curso: @id_curso).select(:id_profesor)
      id_profesor = consulta_db.first[:id_profesor]

      @profesor = Profesor.new(id_profesor)
    end


    @profesor
  end

  
  # Obtiene el nombre del curso 
  # * *Returns* :
  #   - Devuelve String con el nombre del curso 
  def nombre
    if @nombre.nil?
      dataset = @@db[:curso].where(:id_moodle => @id_curso).select(:nombre_curso)
      @nombre = dataset.first[:nombre_curso]
    end
    @nombre
  end  

  #  Establece las entregas del curso 
  def establecer_entregas_curso(entregas)
    @entregas = entregas
  end

  # Asocia un chat de Teleggram al curso 
  #
  #   # * *Args*    :
  #   - +nombre_chat_telegram+ -> nombre del chat de telegram al cual se va a asociar al curso 
  def asociar_chat(nombre_chat_telegram)
    if nombre_chat_telegram.size < 50 && verificar_entrada_texto(nombre_chat_telegram)
      chat = @@db[:chat_curso].where(id_moodle_curso: @id_curso)
        if chat.empty?
          @@db[:chat_telegram].insert(nombre_chat: nombre_chat_telegram.titleize)
          @@db[:chat_curso].insert(nombre_chat_telegram: nombre_chat_telegram.titleize, id_moodle_curso: @id_curso)
        else
          @@db[:chat_telegram].where(nombre_chat: chat.first[:nombre_chat_telegram]).update(nombre_chat: nombre_chat_telegram.titleize)
        end
    end
  end  

  # Devuelve las entregas abiertas para el curso 
  #
  # * *Returns* :
  #   - Devuelve un array con las entregas del curso 
  
  def entregas
      # Se refreca cada vez que se consultan las entregas consultando moodle para evitar almacenar para siempre jamas las entregas que se consultaron por primera vez
    @entregas = []
      datos_curso = @@moodle.api('mod_assign_get_assignments', 'courseids[0]' => @id_curso)
      entregas = datos_curso['courses'][0]['assignments']

      entregas.each { |entrega|
        fecha_convertida = Time.at(entrega['duedate'].to_i).to_datetime
        fecha_convertida = Time.at(entrega['duedate'].to_i).strftime('%Y-%m-%d %H:%M:%S')
        @entregas << Entrega.new(entrega['id'], fecha_convertida, entrega['name'])
        if entrega['intro']
          @entregas.last.descripcion = entrega['intro']
        end
      }

      @entregas
  end
 # Añade una duda al curso 
  #
  #   # * *Args*    :
  #   - +duda+ -> nueva duda a añadir al curso 

  def nueva_duda(duda)
    if duda.contenido.size < 600 && verificar_entrada_texto(duda.contenido)

      @@db[:dudas].insert(id_usuario_duda: duda.usuario.id_telegram, contenido_duda: duda.contenido)
      @@db[:dudas_curso].insert(id_usuario_duda: duda.usuario.id_telegram, id_moodle_curso: @id_curso, contenido_duda: duda.contenido)
    end
  end

  #Obtiene las dudas sin resolver que tiene el curso 
  #
  # * *Returns* :
  #   - Devuelve un array con las dudas sin resolver del curso 
  def obtener_dudas_sin_resolver
    dudas_sin_resolver_curso = []
      datos_dudas_curso = @@db[:dudas_curso].where(id_moodle_curso: @id_curso).select(:id_usuario_duda, :contenido_duda).except(@@db[:dudas_resueltas]).to_a
      datos_dudas_curso.each { |datos_duda|
        dudas_sin_resolver_curso << Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))
      }

      dudas_sin_resolver_curso
  end

  #Obtiene las dudas que tienen solución que tiene el curso 
  #
  # * *Returns* :
  #   - Devuelve un array con las dudas obtenidas 
  def obtener_dudas_resueltas
    dudas_curso = @@db[:dudas_curso].where(id_moodle_curso: @id_curso).select(:id_usuario_duda, :contenido_duda)
    dudas_resueltas = @@db[:dudas_resueltas]
    datos_dudas_resueltas_curso = dudas_curso.where(:contenido_duda => dudas_resueltas.select(:contenido_duda), :id_usuario_duda => dudas_resueltas.select(:id_usuario_duda)).to_a
    dudas_resueltas_curso = []
    datos_dudas_resueltas_curso.each { |datos_duda|
      dudas_resueltas_curso << Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))
    }

    dudas_resueltas_curso
  end

  # Obtiene  todas las dudas del curso 
  #
  # * *Returns* :
  #   - Devuelve un array con todas las dudas 
  #
     def dudas
    dudas_curso = []
    datos_dudas_curso = @@db[:dudas_curso].where(id_moodle_curso: @id_curso).select(:id_usuario_duda, :contenido_duda).to_a
    datos_dudas_curso.each { |datos_duda|
      dudas_curso << Duda.new(datos_duda[:contenido_duda], UsuarioRegistrado.new(datos_duda[:id_usuario_duda]))
    }

    dudas_curso
  end

 # Elimina una duda del curso 
  #
  #   # * *Args*    :
  #   - +duda+ -> duda a eliminar del curso

   def eliminar_duda(duda)
    @@db[:dudas].where(id_usuario_duda: duda.usuario.id_telegram, contenido_duda: duda.contenido).delete
  end

end

require_relative 'profesor'
require_relative 'estudiante'
require_relative 'duda'
