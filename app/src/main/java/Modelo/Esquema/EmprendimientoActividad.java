package Modelo.Esquema;

public class EmprendimientoActividad {
    private Integer idEmprendimiento;
    private Integer idActividad;
    private String observacion;

    public Integer getIdEmprendimiento() {
        return this.idEmprendimiento;
    }

    public void setIdEmprendimiento(Integer idEmprendimiento) {
        this.idEmprendimiento = idEmprendimiento;
    }

    public Integer getIdActividad() {
        return this.idActividad;
    }

    public void setIdActividad(Integer idActividad) {
        this.idActividad = idActividad;
    }

    public String getObservacion() {
        return this.observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

}