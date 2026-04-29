package Modelo.Esquema;

public abstract class Persona {
    protected String cedula;
    protected String nombre;
    protected String apellido;
    protected String telefono;
    protected String correo;

    public Persona(String cedula, String nombre, String apellido, String correo) {
        this.cedula=cedula;
        this.nombre=nombre;
        this.apellido=apellido;
        this.correo=correo;
    }

    public String getCedula() {
        return this.cedula;
    }

    public void setCedula(String cedula) {
        this.cedula = cedula;
    }

    public String getNombre() {
        return this.nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return this.apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getTelefono() {
        return this.telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return this.correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

}