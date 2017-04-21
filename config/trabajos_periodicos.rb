require 'rufus-scheduler'

module TrabajosPeriodicos

  private
  def self.obtener_fecha_proxima_tutoria dia_semana, hora

    fecha=Date.today + ((dia_semana - Date.today.wday) % 7)

    hora_partida=hora.split(":")
    if hora_partida.empty?
      hora_partida=hora.split(" ")
    end


    if hora_partida.size < 3
      hora= Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    else
      hora= Time.new(fecha.year, fecha.month, fecha.day, hora_partida[0], hora_partida[1], '0')
    end

    return hora
  end


  public
  # Actualiza las fechas de las tutorias de los profesores cuya fecha ya ha pasado
  def self.actualizar_tutorias
    scheduler = Rufus::Scheduler.new
    scheduler.cron '32 18 * * *' do
      db=Sequel.connect(ENV['URL_DATABASE'])


      #Obtenemos las tutorias cuya fecha y hora sea anterior a hoy
      tutorias = db[:tutoria].where('dia_semana_hora < ?', Time.now).select(:dia_semana_hora,:id_profesor).to_a

      tutorias.each{ |tutoria|
        puts tutoria[:dia_semana_hora]
        #Borro todas las peticiones para esta tutoria que tengan como fecha anterior la dia_semana_hora de esta tutoria
        peticiones=db[:peticion_tutoria].where(:dia_semana_hora => tutoria[:dia_semana_hora], :id_profesor => tutoria[:id_profesor])
        peticiones.where('hora_solicitud < ?', tutoria[:dia_semana_hora]).delete

        #Actualizo la proxima fecha en la que tendra lugar la tutoria
        hora= tutoria[:dia_semana_hora].hour.to_s + ":" + tutoria[:dia_semana_hora].min.to_s
        fecha_proxima_tutoria=obtener_fecha_proxima_tutoria(tutoria[:dia_semana_hora].wday, hora)
        db[:tutoria].where(:dia_semana_hora => tutoria[:dia_semana_hora], :id_profesor => tutoria[:id_profesor]).update(:dia_semana_hora => fecha_proxima_tutoria)
      }
    end

  end






end