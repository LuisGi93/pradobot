
require_relative 'borrar_tutorias'
require_relative 'peticiones_pendientes'
require_relative 'ver_informacion_tutorias'
require_relative '../menu_inline_telegram'
##Esta clase es como una especie de menu proxi entre menu_tutorias y las acciontes borrar, pendientes e informacion
class AccionSobreTutoria < Accion
  attr_accessor :tutoria
  @nombre="Gestionar tutorías"
  def initialize
    @tutorias=Array.new
    @tutoria=nil
    @dudas=Array.new
    @indice_duda_seleccionada=nil
    @fase=nil
    @ultimo_mensaje=nil
  end

  def solicitar_seleccion_tutoria modo
      @accion=nil
      @tutoria=nil
      if @tutorias.empty?
        @tutorias=@profesor.obtener_tutorias
      end

      mensaje=""
      if @tutorias.empty?
        mensaje="No tiene ninguna tutoría creada."
        @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: mensaje, parse_mode: "Markdown"  )

      else
          indices_tutoria=[*0..@tutorias.size-1]
          indices_menu=MenuInlineTelegram.crear_menu_indice(indices_tutoria, "tutoria", "final" )
          @tutorias.each_with_index { |tutoria, index|

              mensaje+= "\n\t (*#{index}*) \t Fecha tutoría: *#{tutoria.fecha}*     \n"
          }

          puts mensaje
          if modo.eql?("editar")
            @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: mensaje, parse_mode: "Markdown", reply_markup: indices_menu)
          else

            @@bot.api.send_message( chat_id: @ultimo_mensaje.usuario.id_telegram, text: mensaje.to_s,reply_markup: indices_menu,  parse_mode: "markdown"  )
        end
      end


  end



  def comprobar_seleccion_tutoria mensaje

      if mensaje.contenido =~ "\#\#\$\$tutoria.*"

        indice_tutoria= datos_mensaje.slice! "#\#$$tutoria"
        indice_tutoria=indice_tutoria.to_i
        @menu_tutorias.cambiar_tutoria(@tutorias.at(indice_tutoria))
        return true
      end
  end

  def recibir_mensaje(mensaje)
    @ultimo_mensaje=mensaje

    if @profesor.nil?
      @profesor=Profesor.new(@ultimo_mensaje.usuario.id_telegram)
    end
    #if @tutoria
        if @accion
          @accion.generar_respuesta_mensaje(mensaje)
        else
            if @tutoria.nil?

            end
          respuesta_segun_accion_pulsada mensaje.datos_mensaje
        end
    #else
     #  solicitar_seleccion_tutoria
    #end
  end


  def reiniciar
    @accion=nil
    @tutoria=nil
  end

def mostrar_opciones_tutoria

    acciones=["Peticiones pendientes de aceptar", "Cola alumnos","Borrar tutoría" , "Volver"]
    menu=MenuInlineTelegram.crear(acciones)
    texto="Tutoría elegida #{@tutoria.fecha}. Elija que desea hacer:"
    @@bot.api.edit_message_text(:chat_id => @ultimo_mensaje.id_chat ,:message_id => @ultimo_mensaje.id_mensaje, text: texto,reply_markup: menu, parse_mode: "Markdown" )

end

  def respuesta_segun_accion_pulsada datos_mensaje
      puts datos_mensaje
    case datos_mensaje
        when /\#\#\$\$tutoria/
          puts "entro"
            indice_tutoria= datos_mensaje.slice! "#\#$$tutoria"
          indice_tutoria=indice_tutoria.to_i
          @tutoria=@tutorias.at(indice_tutoria)
         mostrar_opciones_tutoria
        when /\#\#\$\$Borrar tutoría/
            @accion=BorrarTutorias.new(self,@tutoria)
            @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Cola alumnos/
            @accion=VerInformacionTutorias.new(self, @tutoria)
            @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Peticiones pendientes de aceptar/
            @accion=PeticionesPendientesTutoria.new(self,@tutoria)
            @accion.generar_respuesta_mensaje(@ultimo_mensaje)
        when /\#\#\$\$Volver/
            solicitar_seleccion_tutoria "editar"
        else
          solicitar_seleccion_tutoria "nuevo"

    end

  end


  public_class_method :new

end
