package Modelo.Esquema;

public class Mentoria {
    private Integer idMentoria;
    private String tema;
    private String contenido;
    private String observacion;
    private String fecha;
    private Double duracionHoras;
    private String modalidad;
    private String locacion;
    private Integer idMentor;
    private Integer idEmprendimiento;

    public Integer getIdMentoria() {
        return this.idMentoria;
    }

    public void setIdMentoria(Integer idMentoria) {
        this.idMentoria = idMentoria;
    }

    public String getTema() {
        return this.tema;
    }

    public void setTema(String tema) {
        this.tema = tema;
    }

    public String getContenido() {
        return this.contenido;
    }

    public void setContenido(String contenido) {
        this.contenido = contenido;
    }

    public String getObservacion() {
        return this.observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public String getFecha() {
        return this.fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public Double getDuracionHoras() {
        return this.duracionHoras;
    }

    public void setDuracionHoras(Double duracionHoras) {
        this.duracionHoras = duracionHoras;
    }

    public String getModalidad() {
        return this.modalidad;
    }

    public void setModalidad(String modalidad) {
        this.modalidad = modalidad;
    }

    public String getLocacion() {
        return this.locacion;
    }

    public void setLocacion(String locacion) {
        this.locacion = locacion;
    }

    public Integer getIdMentor() {
        return this.idMentor;
    }

    public void setIdMentor(Integer idMentor) {
        this.idMentor = idMentor;
    }

    public Integer getIdEmprendimiento() {
        return this.idEmprendimiento;
    }

    public void setIdEmprendimiento(Integer idEmprendimiento) {
        this.idEmprendimiento = idEmprendimiento;
    }

}