package Modelo.Esquema;


public class FilaStaffEvento {
    private Integer idStaff;
    private String nombre;
    private String cargo;
    private double horas;
    private String observacion;

    public FilaStaffEvento(Integer id, String n, String c, double h, String o) {
        this.idStaff = id;
        this.nombre = n;
        this.cargo = c;
        this.horas = h;
        this.observacion = o;
    }


    public Integer getIdStaff() { return idStaff; }
    public String getNombre() { return nombre; }
    public String getCargo() { return cargo; }
    public double getHoras() { return horas; }
    public String getObservacion() { return observacion; }


    public void setHoras(Integer horas) { this.horas = horas; }
    public void setObservacion(String obs) { this.observacion = obs; }
}