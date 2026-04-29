package Modelo.Esquema;

public class Miembro {
    private Integer idMiembro;
    private Integer horasSemana;
    private String fechaIngreso;
    private String fechaSalida;
    private Integer idEmprendimiento;
    private String cedulaPersona;
    private Integer idCarrera;

    public Integer getIdMiembro() {
        return this.idMiembro;
    }

    public void setIdMiembro(Integer idMiembro) {
        this.idMiembro = idMiembro;
    }

    public Integer getHorasSemana() {
        return this.horasSemana;
    }

    public void setHorasSemana(Integer horasSemana) {
        this.horasSemana = horasSemana;
    }

    public String getFechaIngreso() {
        return this.fechaIngreso;
    }

    public void setFechaIngreso(String fechaIngreso) {
        this.fechaIngreso = fechaIngreso;
    }

    public String getFechaSalida() {
        return this.fechaSalida;
    }

    public void setFechaSalida(String fechaSalida) {
        this.fechaSalida = fechaSalida;
    }

    public Integer getIdEmprendimiento() {
        return this.idEmprendimiento;
    }

    public void setIdEmprendimiento(Integer idEmprendimiento) {
        this.idEmprendimiento = idEmprendimiento;
    }

    public String getCedulaPersona() {
        return this.cedulaPersona;
    }

    public void setCedulaPersona(String cedulaPersona) {
        this.cedulaPersona = cedulaPersona;
    }

    public Integer getIdCarrera() {
        return this.idCarrera;
    }

    public void setIdCarrera(Integer idCarrera) {
        this.idCarrera = idCarrera;
    }

}