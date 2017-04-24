class CursoM
    attr_reader :id_curso, :nombre_curso, :entregas
    def initialize  id_curso, nombre_curso
      @id_curso=id_curso
      @nombre_curso=nombre_curso
    end

    def establecer_entregas_curso entregas
      @entregas=entregas
    end
end