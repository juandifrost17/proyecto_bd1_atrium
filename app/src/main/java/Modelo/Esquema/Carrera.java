package Modelo.Esquema;

public class Carrera {
    private Integer idCarrera;
    private String carrera;
    private Integer idFacultad;

    public Integer getIdCarrera() {
        return this.idCarrera;
    }

    public void setIdCarrera(Integer idCarrera) {
        this.idCarrera = idCarrera;
    }

    public String getCarrera() {
        return this.carrera;
    }

    public void setCarrera(String carrera) {
        this.carrera = carrera;
    }

    public Integer getIdFacultad() {
        return this.idFacultad;
    }

    public void setIdFacultad(Integer idFacultad) {
        this.idFacultad = idFacultad;
    }

}