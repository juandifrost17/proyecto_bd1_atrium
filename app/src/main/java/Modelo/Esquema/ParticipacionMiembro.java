package Modelo.Esquema;

public class ParticipacionMiembro {
    private Integer idMiembro;
    private Integer idMentoria;
    private Double participacion;

    public Integer getIdMiembro() {
        return this.idMiembro;
    }

    public void setIdMiembro(Integer idMiembro) {
        this.idMiembro = idMiembro;
    }

    public Integer getIdMentoria() {
        return this.idMentoria;
    }

    public void setIdMentoria(Integer idMentoria) {
        this.idMentoria = idMentoria;
    }

    public Double getParticipacion() {
        return this.participacion;
    }

    public void setParticipacion(Double participacion) {
        this.participacion = participacion;
    }

}