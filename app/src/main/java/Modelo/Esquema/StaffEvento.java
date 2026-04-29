package Modelo.Esquema;

public class StaffEvento {
    private Integer idEvento;
    private Integer idStaff;
    private double horasAsignadas;
    private String observacion;

    public Integer getIdEvento() {
        return this.idEvento;
    }

    public void setIdEvento(Integer idEvento) {
        this.idEvento = idEvento;
    }

    public Integer getIdStaff() {
        return this.idStaff;
    }

    public void setIdStaff(Integer idStaff) {
        this.idStaff = idStaff;
    }

    public double getHorasAsignadas() {
        return this.horasAsignadas;
    }

    public void setHorasAsignadas(double horasAsignadas) {
        this.horasAsignadas = horasAsignadas;
    }

    public String getObservacion() {
        return this.observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

}