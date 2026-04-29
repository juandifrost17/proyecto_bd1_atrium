package Modelo.Esquema;

public class StaffVista {
    private int idStaff;
    private String nombreCompleto;
    private String cargo;


    private String tareaAsignada;
    private double horasAsignadas;

    public StaffVista() {}


    public StaffVista(int idStaff, String nombreCompleto, String cargo) {
        this.idStaff = idStaff;
        this.nombreCompleto = nombreCompleto;
        this.cargo = cargo;
    }


    public int getIdStaff() { return idStaff; }
    public void setIdStaff(int idStaff) { this.idStaff = idStaff; }

    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }

    public String getCargo() { return cargo; }
    public void setCargo(String cargo) { this.cargo = cargo; }

    public String getTareaAsignada() { return tareaAsignada; }
    public void setTareaAsignada(String tareaAsignada) { this.tareaAsignada = tareaAsignada; }

    public double getHorasAsignadas() { return horasAsignadas; }
    public void setHorasAsignadas(double horasAsignadas) { this.horasAsignadas = horasAsignadas; }

    @Override
    public String toString() {
        return nombreCompleto + " - " + cargo;
    }
}