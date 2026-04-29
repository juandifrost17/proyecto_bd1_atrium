package InterfazGrafica.Modulos;

import InterfazGrafica.VistasReportes.VistaReporteIndividual;
import InterfazGrafica.VistasReportes.VistaReporteOperativo;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;

public class ModuloReportes extends BorderPane {

    private VistaReporteIndividual vistaRendimiento;
    private VistaReporteOperativo vistaOperativo;

    private ComboBox<String> cmbTipoReporte;

    public ModuloReportes() {
        inicializarComponentes();
    }

    private void inicializarComponentes() {
        this.setPadding(new Insets(15));


        HBox header = new HBox(20);
        header.setAlignment(Pos.CENTER_LEFT);
        header.setPadding(new Insets(0, 0, 15, 0));

        Label lblTitulo = new Label("Módulo de Reportes");
        lblTitulo.setStyle("-fx-font-size: 20px; -fx-font-weight: bold;");

        cmbTipoReporte = new ComboBox<>();
        cmbTipoReporte.getItems().addAll(
                "Reporte de Rendimiento de Emprendimiento",
                "Reporte de Asistencias y Oportunidades"
        );
        cmbTipoReporte.setPrefWidth(300);
        cmbTipoReporte.getSelectionModel().selectFirst();


        cmbTipoReporte.setOnAction(e -> cambiarVista());

        header.getChildren().addAll(lblTitulo, new Label("Ver:"), cmbTipoReporte);
        this.setTop(header);


        vistaRendimiento = new VistaReporteIndividual();
        vistaOperativo = new VistaReporteOperativo();


        this.setCenter(vistaRendimiento);
    }

    private void cambiarVista() {
        int index = cmbTipoReporte.getSelectionModel().getSelectedIndex();

        if (index == 0) {

            this.setCenter(vistaRendimiento);
        } else {

            vistaOperativo.cargarDatos();
            this.setCenter(vistaOperativo);
        }
    }
}