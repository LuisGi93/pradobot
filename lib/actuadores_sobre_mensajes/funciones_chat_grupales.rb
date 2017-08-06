require_relative '../moodle_api'
module FuncionesChatsGrupales


  def mostrar_entregas_del_curso id_chat, id_moodle_curso
      puts "El id de moodle es #{id_moodle_curso}"
    curso_con_entregas=@moodle.obtener_entregas_curso(id_moodle_curso)

    entregas=curso_con_entregas.entregas

    if entregas.empty?
      texto="Actualmente el curso no cuenta con ninguna entrega."
    else
      texto="Las próximas entregas son:\n"
      entregas.each_with_index { |entrega, indice|
        texto=texto+"    (*#{indice}*): \t *Nombre*: #{entrega.nombre}\n\t*Fecha entrega*: #{entrega.fecha_fin}\n"
      }
    end

    @bot.api.send_message( chat_id: id_chat, text: texto, parse_mode: 'Markdown' )

  end

  def  descripcion_completa_entrega entrega
      texto="*Nombre:* #{entrega.nombre}
      *Fecha entrega:* #{entrega.fecha_fin}
      *Descripcion*:#{entrega.descripcion}"
      return texto
  end



end
