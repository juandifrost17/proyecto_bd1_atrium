package InterfazGrafica.VistasFormulario;

import BaseDatos.StaffDAO;
import Modelo.Esquema.StaffVista;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.util.List;
import java.util.stream.Collectors;

public class VistaStaff extends VBox {


    private ComboBox<StaffVista> cmbStaff;
    private TextField txtTarea;
    private Spinner<Double> spnHoras;
    private Button btnAgregar;


    private Label lblResumenEvento;


    private TableView<StaffVista> tablaAsignados;
    private ObservableList<StaffVista> listaSeleccionados;

    public VistaStaff() {
        this.setPadding(new Insets(20));
        this.setSpacing(15);

        Label lblTitulo = new Label("Asignación de Staff y Tareas");
        lblTitulo.setStyle("-fx-font-size: 18px; -fx-font-weight: bold;");

        lblResumenEvento = new Label("Detalles del evento...");
        lblResumenEvento.setStyle("-fx-text-fill: #2980b9; -fx-font-weight: bold; -fx-padding: 0 0 10 0;");

        VBox panelFormulario = crearFormulario();
        crearTablaResumen();


        VBox.setVgrow(tablaAsignados, Priority.ALWAYS);

        this.getChildren().addAll(lblTitulo, lblResumenEvento, panelFormulario, tablaAsignados);
    }

    private VBox crearFormulario() {
        VBox box = new VBox(10);

        box.setStyle("-fx-background-color: #f4f4f4; -fx-padding: 15; -fx-background-radius: 5; -fx-border-color: #dcdcdc;");


        cmbStaff = new ComboBox<>();
        cmbStaff.setPromptText("Seleccione miembro nuevo...");
        cmbStaff.setMaxWidth(Double.MAX_VALUE);
        cargarStaffDisponible();


        HBox filaDetalles = new HBox(15);

        txtTarea = new TextField();
        txtTarea.setPromptText("Tarea específica (Ej: Logística, Audio)");
        HBox.setHgrow(txtTarea, Priority.ALWAYS);

        Label lblHrs = new Label("Horas:");
        lblHrs.setStyle("-fx-alignment: center-right; -fx-padding: 5 0 0 0;");

        spnHoras = new Spinner<>(0.5, 24.0, 4.0, 0.5);
        spnHoras.setEditable(true);
        spnHoras.setPrefWidth(80);

        filaDetalles.getChildren().addAll(
                new Label("Tarea:"), txtTarea,
                lblHrs, spnHoras
        );


        btnAgregar = new Button("ASIGNAR AL EVENTO");

        btnAgregar.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-weight: bold; -fx-font-size: 13px; -fx-cursor: hand;");
        btnAgregar.setMaxWidth(Double.MAX_VALUE);
        btnAgregar.setPrefHeight(35);
        btnAgregar.setOnAction(e -> agregarALista());

        box.getChildren().addAll(new Label("Personal Disponible:"), cmbStaff, filaDetalles, btnAgregar);
        return box;
    }

    private void crearTablaResumen() {
        tablaAsignados = new TableView<>();
        listaSeleccionados = FXCollections.observableArrayList();
        tablaAsignados.setItems(listaSeleccionados);

        tablaAsignados.setPlaceholder(new Label("No hay staff asignado a este evento aún."));
        tablaAsignados.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY);




        TableColumn<StaffVista, String> colNombre = new TableColumn<>("Nombre");
        colNombre.setCellValueFactory(new PropertyValueFactory<>("nombreCompleto"));

        TableColumn<StaffVista, String> colCargo = new TableColumn<>("Cargo Original");
        colCargo.setCellValueFactory(new PropertyValueFactory<>("cargo"));

        TableColumn<StaffVista, String> colTarea = new TableColumn<>("Tarea en Evento");
        colTarea.setCellValueFactory(new PropertyValueFactory<>("tareaAsignada"));

        TableColumn<StaffVista, Double> colHoras = new TableColumn<>("Horas");
        colHoras.setCellValueFactory(new PropertyValueFactory<>("horasAsignadas"));


        TableColumn<StaffVista, Void> colAccion = new TableColumn<>("Acción");
        colAccion.setCellFactory(param -> new TableCell<>() {
            private final Button btnEliminar = new Button("Quitar");
            {
                btnEliminar.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-font-size: 10px;");
                btnEliminar.setOnAction(event -> {
                    getTableView().getItems().remove(getIndex());
                });
            }
            @Override
            protected void updateItem(Void item, boolean empty) {
                super.updateItem(item, empty);
                setGraphic(empty ? null : btnEliminar);
            }
        });

        tablaAsignados.getColumns().addAll(colNombre, colCargo, colTarea, colHoras, colAccion);
    }

    private void agregarALista() {
        StaffVista seleccionado = cmbStaff.getValue();
        if (seleccionado == null) {
            mostrarAlerta("Selecciona un miembro del staff."); return;
        }
        if (txtTarea.getText().isEmpty()) {
            mostrarAlerta("Debes indicar la tarea a realizar."); return;
        }


        StaffVista asignacion = new StaffVista(
                seleccionado.getIdStaff(),
                seleccionado.getNombreCompleto(),
                seleccionado.getCargo()
        );
        asignacion.setTareaAsignada(txtTarea.getText());
        asignacion.setHorasAsignadas(spnHoras.getValue());

        listaSeleccionados.add(asignacion);


        cmbStaff.getSelectionModel().clearSelection();
        txtTarea.clear();
        cmbStaff.requestFocus();
    }

    private void cargarStaffDisponible() {
        StaffDAO dao = new StaffDAO();
        List<StaffVista> todos = dao.listarStaffCompleto();


        List<StaffVista> filtrados = todos.stream()
                .filter(s -> s.getCargo() == null || !s.getCargo().equalsIgnoreCase("Coordinador"))
                .collect(Collectors.toList());

        cmbStaff.getItems().setAll(filtrados);
    }

    private void mostrarAlerta(String mensaje) {
        Alert alert = new Alert(Alert.AlertType.WARNING);
        alert.setHeaderText(null);
        alert.setContentText(mensaje);
        alert.showAndWait();
    }



    public void setResumenEvento(String texto) {
        if(lblResumenEvento != null) lblResumenEvento.setText(texto);
    }



    public void actualizarLimiteHoras(double maxHoras) {
        if (spnHoras == null) return;


        double techo = (maxHoras > 0) ? maxHoras : 1.0;


        double valorActual = spnHoras.getValue();


        if (valorActual > techo) {
            valorActual = techo;
        }


        SpinnerValueFactory.DoubleSpinnerValueFactory factory =
                new SpinnerValueFactory.DoubleSpinnerValueFactory(0.5, techo, valorActual, 0.5);

        spnHoras.setValueFactory(factory);
    }

    public ObservableList<StaffVista> obtenerStaffSeleccionado() {
        return listaSeleccionados;
    }

    public void limpiarTabla() {

        listaSeleccionados.clear();
        cmbStaff.getSelectionModel().clearSelection();
        txtTarea.clear();
    }

}

