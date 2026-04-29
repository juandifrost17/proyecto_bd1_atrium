package Modelo.Esquema;

public class Mentor {
    private Integer idMentor;
    private String especialidad;
    private Boolean activo;
    private String cedulaPersona;

    public Integer getIdMentor() {
        return this.idMentor;
    }

    public void setIdMentor(Integer idMentor) {
        this.idMentor = idMentor;
    }

    public String getEspecialidad() {
        return this.especialidad;
    }

    public void setEspecialidad(String especialidad) {
        this.especialidad = especialidad;
    }

    public Boolean getActivo() {
        return this.activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public String getCedulaPersona() {
        return this.cedulaPersona;
    }

    public void setCedulaPersona(String cedulaPersona) {
        this.cedulaPersona = cedulaPersona;
    }

}