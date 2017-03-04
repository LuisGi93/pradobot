
require_relative '../estado/admin'

class Profesor

  private :obtener_profesor, :comprobar_existencia_usuario
  def initialize(estado)
    @historial_mensajes=estado
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @moodle=Moodle.new(ENV['TOKEN_MANAGER_MOODLE'])
  end

  def obtener_profesor_registrado_bd(email)
    @db[:usuarios_moodle].where(:email => email, :tipo_usuario => "profesor").select(:nombre).to_a
  end
  def obtener_estudiante_registrado_bd(email)
    @db[:usuarios_moodle].where(:email => email, :tipo_usuario => "estudiante").select(:nombre).to_a
  end

  def obtener_usuario_moodle email
    params={'criteria[0][key]' => 'email', 'criteria[0][value]'  => email}
    usuario=@moodle.api('core_user_get_users ', params )['users']
  end

  def obtener_profesor_moodle

  def comprobar_existencia_usuario email
    profesores =obtener_profesor(email)
    if profesores.empty?
      params={'criteria[0][key]' => 'email', 'criteria[0][value]'  => email}
      profesores=@moodle.api('core_user_get_users ', params )['users']
      puts "Los profesores son #{profesores}"
    end
    return profesores
  end



  def obtener_cursos_profesor(email)
    params={'field' => 'email', 'values[0]' => email}
    salida=@moodle.api('core_user_get_users_by_field', params )[0]

    if salida
      salida=salida['id']


    puts "El id del profesor en moodle es #{salida}" ## tengo el id del usuario con email manager@manager.com


    params={'userid' => salida}
    cursos=@moodle.api('core_enrol_get_users_courses', params )

    id_cursos=Array.new
    cursos.each{|curso|
      id_cursos << curso['id']
    }
=begin
    Aqui solo se coge el primer curso hay que filtrar por todos los cursos en los qu está enrolado
    y solamente devolver los cursos en los que puede acceder via rest y que ademas tiene capacidad de profesor.
    puts "El id del curso es #{id_curso.to_s}" ## tengo el id del usuario con email manager@manager.com
=end

    cursos=Array.new

      params = Hash.new
      for i in 0..id_cursos.size-1
        params["coursecapabilities[#{i}][courseid]"] = id_cursos[i]
        #params["coursecapabilities[#{i}][capabilities][0]"] = 'mod/assign:managegrades'
        params["coursecapabilities[#{i}][capabilities][0]"] = 'webservice/rest:use'

      end
      puts params
      salida=@moodle.api('core_enrol_get_enrolled_users_with_capability', params )

      salida2=Array.new

      salida.each{|course|
        gool=false
        course['users'].each{|usuario|
          if usuario['email'].eql?(email)
            gool=true
          end
        }
        if gool
          salida2 << course
        end
      }
=begin
      id_cursos.each{|id|
      params={'coursecapabilities[0][courseid]' => id, 'coursecapabilities[0][capabilities][0]' => 'mod/assign:managegrades'#,
              #'coursecapabilities[0][capabilities][1]' => 'webservice/rest:use'
      }
      salida=@moodle.api('core_enrol_get_enrolled_users_with_capability', params )
      if salida
          cursos << salida
      end

    }
=end
    puts "\n\n\n\n\n\n\n"
    puts "Los cursos del profesor son: #{salida}"

    if cursos
      cursos.each{|curso|
       #   puts curso[0].class.to_s#"curso_id= #{curso['courseid']}"
          puts "\n\n\n\n\nHash"
        #  puts curso[0].to_s
          puts "\n\n\n\n\nArray"
         # puts curso.to_s
      }
    end
    end
    return salida2
  end

  def inicializar_profesor(mensaje, bot)
    id_profesor=mensaje.from.id
    profesor =@db.from(:usuarios_telegram).where(:id_telegram => id_profesor).select(:tipo_usuario => "profesor").to_a
    estado_sesion_actual=@sesion_actual.obtener_estado_actual(id_profesor)
    puts "No tengo ni idea de que soy #{profesor.to_s}"
    puts estado_sesion_actual
    if profesor.empty? &&estado_sesion_actual.nil?

      @sesion_actual.establecer_estado(id_profesor, "inicio_profesor")
      @sesion_actual.actualizar_estado(id_profesor, "inicio")
      estado_sesion_actual=@sesion_actual.obtener_estado_actual(id_profesor)
      puts "Estado es  #{estado_sesion_actual.to_s}"


      bot.api.send_message(chat_id: mensaje.chat.id, text: 'Para empezar a utilizar el bot es necesario identificarse con moodle. Introduzca su email:')
    else
      puts "Vamos al case #{estado_sesion_actual["inicio_profesor"]}"
      case estado_sesion_actual["inicio_profesor"]
        when "inicio"
          email=mensaje.text
          existe=comprobar_existencia_usuario(email)
          puts "Lalaland #{existe.class.to_s}"
          if existe.nil? || existe.empty?
            texto= "Error: Usuario inexistente, vuelva a intentarlo."
          else
            #@db.from(:usuarios_moodle).insert(:id_telegram => mensaje.from.id, :email => email, :tipo_usuario => "profesor",  :fecha_alta => Time.now )
            texto = "Usuario existente procedemos a obtener los cursos de #{email}."
          end

          bot.api.send_message(chat_id: mensaje.chat.id, text: texto)
          cursos_profesor=obtener_cursos_profesor(email)
          bot.api.send_message(chat_id: mensaje.chat.id, text: 'Los cursos del profesor son:')


          cursos_profesor.each{|curso|
            bot.api.send_message(chat_id: mensaje.chat.id, text: curso['courseid'])

         }
          bot.api.send_message(chat_id: mensaje.chat.id, text: 'Fin')


      end
    end




  end


end