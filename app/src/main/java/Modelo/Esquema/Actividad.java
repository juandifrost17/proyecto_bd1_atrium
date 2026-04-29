package Modelo.Esquema;

public class Actividad {
    private Integer idActividad;
    private String tipo;
    private String nombre;
    private String descripcion;
    private String fecha;
    private Double duracionHoras;
    private Integer idExpositor;
    private Integer idLugar;

    public Integer getIdActividad() {
        return this.idActividad;
    }

    public void setIdActividad(Integer idActividad) {
        this.idActividad = idActividad;
    }

    public String getTipo() {
        return this.tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getNombre() {
        return this.nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return this.descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
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

    public Integer getIdExpositor() {
        return this.idExpositor;
    }

    public void setIdExpositor(Integer idExpositor) {
        this.idExpositor = idExpositor;
    }

    public Integer getIdLugar() {
        return this.idLugar;
    }

    public void setIdLugar(Integer idLugar) {
        this.idLugar = idLugar;
    }

}