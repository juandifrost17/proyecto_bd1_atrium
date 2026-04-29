package Modelo.Esquema;

public class Staff extends Persona {
    private Integer idStaff;
    private String cargo;
    private Boolean activo;
    private String cedulaPersona;

    public Staff(String cedula, String nombre, String apellido, String correo,
                 String cargo, Boolean activo) {
        super(cedula, nombre, apellido, correo);
        this.cargo = cargo;
        this.activo = activo;
    }

    public Integer getIdStaff() {
        return this.idStaff;
    }

    public void setIdStaff(Integer idStaff) {
        this.idStaff = idStaff;
    }

    public String getCargo() {
        return this.cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
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
    @Override
    public String toString() {

        return getNombre() + " " + getApellido() + " (" + this.cargo + ")";
    }
}