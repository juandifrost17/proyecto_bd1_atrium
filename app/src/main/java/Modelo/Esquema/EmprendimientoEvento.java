package Modelo.Esquema;

public class EmprendimientoEvento {
    private Integer idEmprendimiento;
    private Integer idEvento;
    private String observacion;

    public Integer getIdEmprendimiento() {
        return this.idEmprendimiento;
    }

    public void setIdEmprendimiento(Integer idEmprendimiento) {
        this.idEmprendimiento = idEmprendimiento;
    }

    public Integer getIdEvento() {
        return this.idEvento;
    }

    public void setIdEvento(Integer idEvento) {
        this.idEvento = idEvento;
    }

    public String getObservacion() {
        return this.observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

}