require_relative '../lib/mensajero'
require_relative '../config/trabajos_periodicos'

TrabajosPeriodicos.actualizar_tutorias
bot =Mensajero.new(ENV['TOKEN_BOT'])
bot.recibir_mensajes

