package InterfazGrafica.VistasFormulario;

import BaseDatos.EmprendimientoDAO;
import Modelo.Esquema.Emprendimiento;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.SelectionMode;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.util.List;

public class VistaEmprendimientos extends VBox {
    private Label lblResumenEvento;


    private ListView<Emprendimiento> listDisponibles;
    private ObservableList<Emprendimiento> datosDisponibles;


    private ListView<Emprendimiento> listSeleccionados;
    private ObservableList<Emprendimiento> datosSeleccionados;

    public VistaEmprendimientos() {
        this.setPadding(new Insets(20));
        this.setSpacing(10);
        this.setAlignment(Pos.TOP_CENTER);

        construirInterfaz();
    }

    private void construirInterfaz() {
        Label lblTitulo = new Label("Selección de Emprendimientos");
        lblTitulo.setStyle("-fx-font-size: 18px; -fx-font-weight: bold; -fx-text-fill: #2c3e50;");

        lblResumenEvento = new Label("Detalles del evento...");
        lblResumenEvento.setStyle("-fx-font-size: 14px; -fx-text-fill: #3498db; -fx-font-weight: bold; -fx-padding: 0 0 10 0;");


        datosDisponibles = FXCollections.observableArrayList();
        datosSeleccionados = FXCollections.observableArrayList();


        EmprendimientoDAO dao = new EmprendimientoDAO();
        datosDisponibles.addAll(dao.listarTodos());

        listDisponibles = new ListView<>(datosDisponibles);
        listSeleccionados = new ListView<>(datosSeleccionados);


        listDisponibles.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE);
        listSeleccionados.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE);


        VBox.setVgrow(listDisponibles, Priority.ALWAYS);
        VBox.setVgrow(listSeleccionados, Priority.ALWAYS);


        VBox boxIzq = new VBox(5, new Label("Disponibles:"), listDisponibles);
        VBox boxDer = new VBox(5, new Label("Asignados al Evento:"), listSeleccionados);


        HBox.setHgrow(boxIzq, Priority.ALWAYS);
        HBox.setHgrow(boxDer, Priority.ALWAYS);


        Button btnMoverDerecha = new Button("Añadir ->");
        Button btnMoverIzquierda = new Button("<- Quitar");


        btnMoverDerecha.setStyle("-fx-background-color: #3498db; -fx-text-fill: white;");
        btnMoverIzquierda.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white;");
        btnMoverDerecha.setPrefWidth(80);
        btnMoverIzquierda.setPrefWidth(80);


        btnMoverDerecha.setOnAction(e -> {

            List<Emprendimiento> seleccion = listDisponibles.getSelectionModel().getSelectedItems();
            if (!seleccion.isEmpty()) {

                List<Emprendimiento> aMover = List.copyOf(seleccion);
                datosSeleccionados.addAll(aMover);
                datosDisponibles.removeAll(aMover);
                listDisponibles.getSelectionModel().clearSelection();
            }
        });


        btnMoverIzquierda.setOnAction(e -> {
            List<Emprendimiento> seleccion = listSeleccionados.getSelectionModel().getSelectedItems();
            if (!seleccion.isEmpty()) {
                List<Emprendimiento> aDevolver = List.copyOf(seleccion);
                datosDisponibles.addAll(aDevolver);
                datosSeleccionados.removeAll(aDevolver);
                listSeleccionados.getSelectionModel().clearSelection();
            }
        });

        VBox boxBotones = new VBox(10, btnMoverDerecha, btnMoverIzquierda);
        boxBotones.setAlignment(Pos.CENTER);
        boxBotones.setPadding(new Insets(0, 10, 0, 10));


        HBox panelDual = new HBox(boxIzq, boxBotones, boxDer);
        panelDual.setPrefHeight(300);

        this.getChildren().addAll(lblTitulo, lblResumenEvento, panelDual);
    }


    public ObservableList<Emprendimiento> obtenerSeleccionados() {
        return datosSeleccionados;
    }


    public void limpiar() {
        datosSeleccionados.clear();
        datosDisponibles.clear();

        EmprendimientoDAO dao = new EmprendimientoDAO();
        datosDisponibles.addAll(dao.listarTodos());
    }
    public void setResumenEvento(String texto) {lblResumenEvento.setText(texto);}
}