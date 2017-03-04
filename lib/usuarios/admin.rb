
require_relative '../estado/admin'
require_relative '../moodle_api'

class Admin

  def initialize(estado)
    @sesion_actual=estado
    @db=Sequel.connect(ENV['URL_DATABASE'])
    @moodle=Moodle.new(ENV['TOKEN_MANAGER_MOODLE'])
  end

  def comprobar_existencia_usuario email
    profesores =@db[:usuarios_moodle].where(:email => email, :tipo_usuario => "profesor").select(:nombre).to_a
    if profesores.empty?
      params={'criteria[0][key]' => 'email', 'criteria[0][value]'  => email}
      profesores=@moodle.api('core_user_get_users ', params )['users']
      puts "Los profesores son #{profesores}"
    end
    return profesores
  end
  def dar_alta_profesor(mensaje, bot)
    id_admin=mensaje.from.id
    estado_sesion_actual=@sesion_actual.obtener_estado_actual(id_admin)

    if mensaje.class == Telegram::Bot::Types::CallbackQuery && mensaje.data == "alta_profesor"
      @sesion_actual.establecer_estado(id_admin, "alta_profesor")
      @sesion_actual.actualizar_estado(id_admin, "introduciendo_email_profesor")


      bot.api.send_message(chat_id: mensaje.message.chat.id, text: 'Es necesario que el usuario exista en moodle. Introduzca el email:')
    else
      case estado_sesion_actual["alta_profesor"]
        when "introduciendo_email_profesor"
          email=mensaje.text
          bot.api.send_message(chat_id: mensaje.chat.id, text: "Email #{email} recibido. Procedemos a verificar la existencia del usuario.")
          estado = "comprobando_email_profesor"
          existe=comprobar_existencia_usuario(email)
          puts "Lalaland #{existe.class.to_s}"
          if existe.nil? || existe.empty?
            texto= "Error: Usuario inexistente, vuelva a intentarlo."
          else
            #@db.from(:usuarios_moodle).insert(:id_telegram => mensaje.from.id, :email => email, :tipo_usuario => "profesor",  :fecha_alta => Time.now )
            @db.from(:usuarios_moodle).insert(:nombre => existe[0]['firstname'], :apellidos => existe[0]['lastname'], :email => email, :contraseña => 'nil',
                                              :id_moodle => existe[0]['id'], :tipo_usuario => "profesor",  :fecha_alta => Time.now )

            texto = "Usuario existente, email #{email} dado de alta con existo."
          end
          bot.api.send_message(chat_id: mensaje.chat.id, text: texto)
          @sesion_actual.reiniciar_estado(id_admin)

          ##Hay que poner condicion por defecto

      end
    end




  end


end