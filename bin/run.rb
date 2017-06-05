require_relative '../lib/manejadores_mensajes/mensajero'
require_relative '../config/trabajos_periodicos'

TrabajosPeriodicos.actualizar_tutorias
bot =Mensajero.new(ENV['TOKEN_BOT'])
bot.empezar_recibir_mensajes

