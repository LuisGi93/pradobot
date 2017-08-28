require 'rake/testtask'
require 'rspec/core/rake_task'
require_relative 'config/crear_tablas_bd'
require 'sequel'



namespace :tasks do
  namespace :db do

    namespace :test do

      desc "Creamos base de datos test"
      task :crear  do
        db=Sequel.connect(ENV['URL_DATABASE'])
        begin
          db.run "CREATE DATABASE bd_prueba"
        rescue Sequel::Error
          db.run "DROP DATABASE bd_prueba"
          db.run "CREATE DATABASE bd_prueba"
        end
        db.disconnect
        db=Sequel.connect(ENV['URL_DATABASE']+'/bd_prueba')
        crear_tablas(db)
        db.disconnect
        ENV['URL_DATABASE_ORIGINAL']=ENV['URL_DATABASE']
        ENV['URL_DATABASE']=ENV['URL_DATABASE_PRUEBA']
      end

      RSpec::Core::RakeTask.new(:tests_bd) do |t|
          t.pattern = Dir.glob('test/test_*.rb')
        t.rspec_opts = '--format documentation'
      end

      desc "Borramos la base de datos"
      task :destruir  do
        ENV['URL_DATABASE']=ENV['URL_DATABASE_ORIGINAL']
        db=Sequel.connect(ENV['URL_DATABASE'])
        db.run "DROP DATABASE bd_prueba"
        db.disconnect
      end

      RSpec::Core::RakeTask.new(:tests_nobd) do |t|
          t.pattern = Dir.glob('test/test_establecer_tutoria.rb')
        t.rspec_opts = '--format documentation'
      end
    end

  end

  namespace :tests do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = Dir.glob('test/test_*.rb')
      t.rspec_opts = '--format documentation'
# t.rspec_opts << ' more options'
    end
  end



end



desc "Ejecutamos los test sobre la base de datos"
task :testbd => ['tasks:db:test:crear', 'tasks:db:test:tests_bd', 'tasks:db:test:destruir' ]
task :testnobd => ['tasks:db:test:tests_nobd' ]

task :default => ['tasks:db:test:tests_nobd']
