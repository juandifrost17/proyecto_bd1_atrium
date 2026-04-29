package InterfazGrafica.Modulos;

import BaseDatos.EventoDAO;
import InterfazGrafica.VistasFormulario.VistaDatosGenerales;
import InterfazGrafica.VistasFormulario.VistaEmprendimientos;
import InterfazGrafica.VistasFormulario.VistaStaff;
import Modelo.Esquema.Emprendimiento;
import Modelo.Esquema.Evento;
import Modelo.Esquema.StaffVista;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.util.List;

public class ModuloEventos extends BorderPane {


    private VistaDatosGenerales vistaGeneral;
    private VistaEmprendimientos vistaEmprendimientos;
    private VistaStaff vistaStaff;

    private Button btnGuardar;
    private Button btnLimpiar;


    private EventoDAO dao;

    public ModuloEventos() {
        this.dao = new EventoDAO();
        inicializarComponentes();
    }

    private void inicializarComponentes() {
        this.setPadding(new Insets(15));


        Label lblTitulo = new Label("Gestión de Eventos");
        lblTitulo.setStyle("-fx-font-size: 24px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");
        BorderPane.setAlignment(lblTitulo, Pos.CENTER);
        this.setTop(lblTitulo);


        vistaGeneral = new VistaDatosGenerales();
        vistaEmprendimientos = new VistaEmprendimientos();
        vistaStaff = new VistaStaff();



        TabPane tabPane = new TabPane();
        tabPane.setTabClosingPolicy(TabPane.TabClosingPolicy.UNAVAILABLE);

        Tab tabGeneral = new Tab("Datos Generales", vistaGeneral);
        Tab tabEmp = new Tab("Emprendimientos", vistaEmprendimientos);
        Tab tabStaff = new Tab("Staff Adicional", vistaStaff);

        tabPane.getTabs().addAll(tabGeneral, tabEmp, tabStaff);

        tabPane.getSelectionModel().selectedItemProperty().addListener((obs, oldTab, newTab) -> {

            String resumen = vistaGeneral.obtenerResumenTexto();


            if (newTab == tabEmp) {
                vistaEmprendimientos.setResumenEvento(resumen);
            }


            else if (newTab == tabStaff) {

                vistaStaff.setResumenEvento(resumen);


                Double duracionEvento = vistaGeneral.getDuracionActual();
                vistaStaff.actualizarLimiteHoras(duracionEvento);
            }
        });

        HBox botonera = new HBox(15);
        botonera.setAlignment(Pos.CENTER_RIGHT);
        botonera.setPadding(new Insets(15, 0, 0, 0));

        btnLimpiar = new Button("Limpiar Formulario");
        btnLimpiar.setStyle("-fx-background-color: #95a5a6; -fx-text-fill: white; -fx-font-weight: bold;");
        btnLimpiar.setOnAction(e -> accionLimpiar());

        btnGuardar = new Button("GUARDAR EVENTO");
        btnGuardar.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-size: 14px; -fx-font-weight: bold;");
        btnGuardar.setPrefHeight(40);
        btnGuardar.setPrefWidth(200);


        btnGuardar.setOnAction(e -> accionGuardar());

        botonera.getChildren().addAll(btnLimpiar, btnGuardar);


        VBox centro = new VBox(10);
        centro.getChildren().addAll(tabPane, botonera);
        VBox.setVgrow(tabPane, Priority.ALWAYS);

        this.setCenter(centro);
    }

    private void accionGuardar() {


        Evento nuevoEvento = vistaGeneral.getEventoRecogido();

        if (nuevoEvento == null) {
            mostrarAlerta("Campos Incompletos", "Por favor llene Nombre, Fecha, Duración y Lugar.", Alert.AlertType.WARNING);
            return;
        }



        String textoCoordinador = vistaGeneral.getCmbCoordinador().getValue();

        if (textoCoordinador == null || textoCoordinador.isEmpty()) {
            mostrarAlerta("Falta Coordinador", "Es obligatorio seleccionar un Coordinador en la pestaña de Datos.", Alert.AlertType.ERROR);
            return;
        }

        int idCoordinador = extraerId(textoCoordinador);
        if (idCoordinador == -1) {
            mostrarAlerta("Error de Formato", "No se pudo obtener el ID del coordinador.", Alert.AlertType.ERROR);
            return;
        }


        List<Emprendimiento> participantes = vistaEmprendimientos.obtenerSeleccionados();






        boolean exito = dao.guardarEventoCompleto(nuevoEvento, idCoordinador, participantes);

        if (exito) {
            mostrarAlerta("¡Éxito!", "El evento se ha creado correctamente, coordinador asignado y participantes inscritos.", Alert.AlertType.INFORMATION);
            accionLimpiar();
        } else {
            mostrarAlerta("Error", "No se pudo guardar el evento. Revise la conexión o los datos.", Alert.AlertType.ERROR);
        }
    }

    private void accionLimpiar() {
        vistaGeneral.limpiarCampos();
        vistaEmprendimientos.limpiar();
        vistaStaff.limpiarTabla();
    }


    private int extraerId(String texto) {
        try {
            if (texto == null) return -1;
            int inicio = texto.lastIndexOf("ID:") + 3;
            int fin = texto.lastIndexOf(")");

            if (inicio > 2 && fin > inicio) {
                String numero = texto.substring(inicio, fin).trim();
                return Integer.parseInt(numero);
            }
            return -1;
        } catch (Exception e) {
            return -1;
        }
    }

    private void mostrarAlerta(String titulo, String contenido, Alert.AlertType tipo) {
        Alert alerta = new Alert(tipo);
        alerta.setTitle(titulo);
        alerta.setHeaderText(null);
        alerta.setContentText(contenido);
        alerta.showAndWait();
    }
}