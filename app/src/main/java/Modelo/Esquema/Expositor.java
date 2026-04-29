package Modelo.Esquema;

public class Expositor {
    private Integer idExpositor;
    private String especialidad;
    private Boolean activo;
    private String cedulaPersona;

    public Integer getIdExpositor() {
        return this.idExpositor;
    }

    public void setIdExpositor(Integer idExpositor) {
        this.idExpositor = idExpositor;
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