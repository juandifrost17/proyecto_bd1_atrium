package InterfazGrafica.VistasFormulario;



import BaseDatos.LugarDAO;
import BaseDatos.StaffDAO;
import Modelo.Esquema.Evento;
import Modelo.Esquema.Lugar;
import Modelo.Esquema.StaffVista;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.VBox;

import java.time.LocalDate;
import java.util.List;

public class VistaDatosGenerales extends VBox {

    private TextField txtNombre;
    private TextArea txtDesc;
    private DatePicker datePicker;
    private Spinner<Double> spnDuracion;
    private ComboBox<Lugar> cmbLugar;


    private ComboBox<String> cmbCoordinador;

    public VistaDatosGenerales() {
        this.setPadding(new Insets(20));
        this.setSpacing(15);
        this.setAlignment(Pos.TOP_LEFT);

        construirFormulario();
    }

    private void construirFormulario() {
        Label lblTitulo = new Label("Datos del Evento Nuevo");
        lblTitulo.setStyle("-fx-font-size: 18px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        GridPane grid = new GridPane();
        grid.setHgap(10);
        grid.setVgap(15);

        txtNombre = new TextField();
        txtNombre.setPromptText("Ej: Hackathon 2025");

        txtDesc = new TextArea();
        txtDesc.setPrefRowCount(3);

        datePicker = new DatePicker();
        datePicker.setEditable(false);
        datePicker.setValue(LocalDate.now());

        spnDuracion = new Spinner<>(0.5, 24.0, 1.0, 0.5);


        cmbLugar = new ComboBox<>();
        LugarDAO lugarDAO = new LugarDAO();
        cmbLugar.getItems().addAll(lugarDAO.listarLugares());
        cmbLugar.setPromptText("Seleccione ubicación...");


        cmbCoordinador = new ComboBox<>();
        StaffDAO staffDAO = new StaffDAO();


        List<StaffVista> todos = staffDAO.listarStaffCompleto();



        for (StaffVista s : todos) {

            String cargoLimpio = (s.getCargo() != null) ? s.getCargo().trim() : "";


            if (cargoLimpio.equalsIgnoreCase("Coordinador")) {
                String etiqueta = s.getNombreCompleto() + " (ID:" + s.getIdStaff() + ")";
                cmbCoordinador.getItems().add(etiqueta);
            }
        }
        cmbCoordinador.setPromptText("Responsable del evento...");






        grid.addRow(0, new Label("Nombre:"), txtNombre);
        grid.addRow(1, new Label("Descripción:"), txtDesc);
        grid.addRow(2, new Label("Fecha:"), datePicker);
        grid.addRow(3, new Label("Duración (Hrs):"), spnDuracion);
        grid.addRow(4, new Label("Lugar:"), cmbLugar);
        grid.addRow(5, new Label("Coordinador:"), cmbCoordinador);

        this.getChildren().addAll(lblTitulo, grid);
    }


    public Evento getEventoRecogido() {
        if (txtNombre.getText().isEmpty() || datePicker.getValue() == null || cmbLugar.getValue() == null) {
            return null;
        }
        Evento e = new Evento();
        e.setNombre(txtNombre.getText());
        e.setDescripcion(txtDesc.getText());


        e.setFecha(datePicker.getValue());

        e.setDuracionHoras(spnDuracion.getValue());
        e.setIdLugar(cmbLugar.getValue().getIdLugar());
        return e;
    }


    public ComboBox<String> getCmbCoordinador() {
        return cmbCoordinador;
    }

    public void limpiarCampos() {
        txtNombre.clear();
        txtDesc.clear();
        datePicker.setValue(null);
        cmbLugar.getSelectionModel().clearSelection();
        cmbCoordinador.getSelectionModel().clearSelection();
    }

    public Double getDuracionActual() {
        return (spnDuracion.getValue() == null) ? 0.0 : spnDuracion.getValue();
    }


    public String obtenerResumenTexto() {
        String nombre = (txtNombre.getText().isEmpty()) ? "(Sin Nombre)" : txtNombre.getText();


        String fecha = "Sin Fecha";
        if (datePicker.getValue() != null) {
            fecha = datePicker.getValue().toString();
        }


        String lugar = "Sin Lugar";
        if (cmbLugar.getValue() != null) {
            lugar = cmbLugar.getValue().getNombre();
        }

        return "Evento: " + nombre + " | Fecha: " + fecha + " | Lugar: " + lugar;
    }


}

