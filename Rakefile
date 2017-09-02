require 'rake/testtask'
require 'rspec/core/rake_task'
require_relative 'config/crear_tablas_bd'
require 'sequel'



namespace :tasks do
  namespace :db do


    namespace :test_travis do

      desc "Creamos base de datos test"
      task :crear  do
        db=Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
        begin
          db.drop_table?(:respuesta_resuelve_duda, :respuesta_duda, :respuestas,:dudas_curso, :dudas_resueltas, :dudas_curso, :dudas,:peticion_tutoria, :tutoria, :datos_moodle, :usuarios_moodle, :profesor_curso, :profesor, :estudiante_curso,:estudiante, :chat_curso, :chat_telegram, :curso,:usuario_telegram )
          crear_tablas(db)
        rescue Sequel::Error
            crear_tablas(db)
        end
      end

      RSpec::Core::RakeTask.new(:tests) do |t|
          t.pattern = Dir.glob('test/test_*.rb')
#          t.pattern = Dir.glob('test/test_informacion_tutoria.rb')

          t.rspec_opts = '--format documentation'
      end

      desc "Borramos la base de datos"
      task :destruir  do
        db=Sequel.connect(ENV['URL_DATABASE_TRAVIS'])
            db.drop_table?(:respuesta_resuelve_duda, :respuesta_duda, :respuestas,:dudas_curso, :dudas_resueltas, :dudas_curso, :dudas,:peticion_tutoria, :tutoria, :datos_moodle, :usuarios_moodle, :profesor_curso, :profesor, :estudiante_curso,:estudiante, :chat_curso, :chat_telegram, :curso, :usuario_telegram )
      end
      
  end

  end


end

desc "Ejecutamos los test sobre la base de datos"

task :default => ['tasks:db:test_travis:crear', 'tasks:db:test_travis:tests', 'tasks:db:test_travis:destruir' ]
