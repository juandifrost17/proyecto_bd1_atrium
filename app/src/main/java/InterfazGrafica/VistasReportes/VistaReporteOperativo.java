package InterfazGrafica.VistasReportes;

import BaseDatos.ReporteDAO;
import Modelo.DTOs.ReporteEmprendimientoDTO;
import Modelo.DTOs.ReporteOperativoDTO;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.stage.FileChooser;

import java.sql.Date;
import java.text.SimpleDateFormat;

public class VistaReporteOperativo extends BorderPane {

    private ListView<ReporteEmprendimientoDTO> listaEmprendimientos;
    private VBox panelDetalle;
    private ReporteOperativoDTO reporteActual;
    private Button btnExportarPDF;

    private Label lblNombre, lblSector, lblEstado, lblFechaReg;


    private Label lblUltMentoria, lblUltActividad, lblUltEvento;


    private Label lblHorasEquipo, lblHorasLider;
    private Label lblHorasMentoria, lblHorasActividad, lblHorasEvento;


    private Label lblActPerdidas, lblEvPerdidos;

    private ReporteDAO dao;

    public VistaReporteOperativo() {
        this.dao = new ReporteDAO();
        this.setPadding(new Insets(10));


        VBox panelIzquierdo = new VBox(5);
        Label lblTituloLista = new Label("Seleccione Emprendimiento:");
        lblTituloLista.setStyle("-fx-font-weight: bold;");

        listaEmprendimientos = new ListView<>();
        listaEmprendimientos.setPrefWidth(250);

        listaEmprendimientos.setCellFactory(param -> new ListCell<>() {
            @Override protected void updateItem(ReporteEmprendimientoDTO item, boolean empty) {
                super.updateItem(item, empty);
                if (empty || item == null) setText(null);
                else {
                    setText(item.getNombre());
                    setStyle("-fx-font-size: 14px; -fx-padding: 5px;");
                }
            }
        });

        listaEmprendimientos.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal != null) cargarDetalleOperativo(newVal.getIdEmprendimiento());
        });

        panelIzquierdo.getChildren().addAll(lblTituloLista, listaEmprendimientos);
        VBox.setVgrow(listaEmprendimientos, Priority.ALWAYS);


        panelDetalle = crearPanelDetalle();

        SplitPane split = new SplitPane(panelIzquierdo, panelDetalle);
        split.setDividerPositions(0.3);
        this.setCenter(split);

        cargarListaInicial();
    }

    private VBox crearPanelDetalle() {
        VBox layout = new VBox(15);
        layout.setPadding(new Insets(20));
        layout.setVisible(false);


        HBox headerBox = new HBox();
        headerBox.setAlignment(Pos.CENTER_LEFT);


        lblNombre = new Label("Nombre");
        lblNombre.setFont(Font.font("Arial", FontWeight.BOLD, 24));
        lblNombre.setStyle("-fx-text-fill: #2c3e50;");


        Region spacer = new Region();
        HBox.setHgrow(spacer, Priority.ALWAYS);


        btnExportarPDF = new Button("Descargar PDF");

        btnExportarPDF.setStyle("-fx-background-color: #000b3d; -fx-text-fill: white; -fx-font-weight: bold; -fx-cursor: hand;");


        btnExportarPDF.setOnAction(e -> exportarReporteActual());


        headerBox.getChildren().addAll(lblNombre, spacer, btnExportarPDF);


        HBox subHeader = new HBox(20);
        lblSector = new Label("-");
        lblEstado = new Label("-");
        lblFechaReg = new Label("-");
        estilizarTag(lblSector, "#3498db");
        estilizarTag(lblEstado, "#e67e22");
        estilizarTag(lblFechaReg, "#7f8c8d");
        subHeader.getChildren().addAll(lblSector, lblEstado, lblFechaReg);


        Label tituloFechas = new Label(" Última Actividad Registrada");
        tituloFechas.setStyle("-fx-font-weight: bold; -fx-font-size: 14px;");

        GridPane gridFechas = new GridPane();
        gridFechas.setHgap(20); gridFechas.setVgap(10);
        gridFechas.addRow(0, new Label("Última Mentoría:"), lblUltMentoria = new Label("-"));
        gridFechas.addRow(1, new Label("Última Actividad:"), lblUltActividad = new Label("-"));
        gridFechas.addRow(2, new Label("Último Evento:"), lblUltEvento = new Label("-"));


        Label tituloHoras = new Label(" Distribución de Tiempo (Horas)");
        tituloHoras.setStyle("-fx-font-weight: bold; -fx-font-size: 14px;");

        GridPane gridHoras = new GridPane();
        gridHoras.setHgap(30); gridHoras.setVgap(10);

        gridHoras.add(new Label("Horas Semanales Equipo:"), 0, 0);
        gridHoras.add(lblHorasEquipo = new Label("0"), 1, 0);
        gridHoras.add(new Label("Horas Semanales Líder:"), 0, 1);
        gridHoras.add(lblHorasLider = new Label("0"), 1, 1);

        gridHoras.add(new Label("Total en Mentorías:"), 2, 0);
        gridHoras.add(lblHorasMentoria = new Label("0"), 3, 0);
        gridHoras.add(new Label("Total en Actividades:"), 2, 1);
        gridHoras.add(lblHorasActividad = new Label("0"), 3, 1);
        gridHoras.add(new Label("Total en Eventos:"), 2, 2);
        gridHoras.add(lblHorasEvento = new Label("0"), 3, 2);


        VBox boxAlertas = new VBox(10);
        boxAlertas.setStyle("-fx-background-color: #fff0f0; -fx-padding: 10; -fx-border-color: #ffcccc; -fx-border-radius: 5;");
        Label tituloAlertas = new Label("Oportunidades No Aprovechadas");
        tituloAlertas.setStyle("-fx-font-weight: bold; -fx-text-fill: #c0392b;");

        HBox boxStatsPerdidas = new HBox(30);
        lblActPerdidas = new Label("0 Actividades perdidas");
        lblEvPerdidos = new Label("0 Eventos perdidos");
        lblActPerdidas.setStyle("-fx-font-weight: bold; -fx-text-fill: #e74c3c;");
        lblEvPerdidos.setStyle("-fx-font-weight: bold; -fx-text-fill: #e74c3c;");

        boxStatsPerdidas.getChildren().addAll(lblActPerdidas, lblEvPerdidos);
        boxAlertas.getChildren().addAll(tituloAlertas, boxStatsPerdidas);



        layout.getChildren().addAll(
                headerBox,
                subHeader,
                new Separator(),
                tituloFechas,
                gridFechas,
                new Separator(),
                tituloHoras,
                gridHoras,
                new Separator(),
                boxAlertas
        );

        return layout;
    }

    private void cargarDetalleOperativo(int idEmprendimiento) {
        ReporteOperativoDTO dto = dao.obtenerReporteOperativo(idEmprendimiento);
        this.reporteActual = dto;
        if (dto != null) {
            lblNombre.setText(dto.getNombre());
            lblSector.setText("Sector: " + dto.getSector());
            lblEstado.setText("Estado: " + dto.getEstado());
            lblFechaReg.setText("Reg: " + formatearFecha(dto.getFechaRegistro()));

            lblUltMentoria.setText(formatearFecha(dto.getFechaUltimaMentoria()));
            lblUltActividad.setText(formatearFecha(dto.getFechaUltimaActividad()));
            lblUltEvento.setText(formatearFecha(dto.getFechaUltimoEvento()));

            lblHorasEquipo.setText(String.format("%.1f hrs", dto.getHorasTotalesEquipo()));
            lblHorasLider.setText(String.format("%.1f hrs", dto.getHorasSemanaLider()));
            lblHorasMentoria.setText(String.format("%.1f hrs", dto.getHorasTotalMentorias()));
            lblHorasActividad.setText(String.format("%.1f hrs", dto.getHorasTotalActividades()));
            lblHorasEvento.setText(String.format("%.1f hrs", dto.getHorasTotalEventos()));

            lblActPerdidas.setText(dto.getActividadesPerdidas() + " Actividades perdidas");
            lblEvPerdidos.setText(dto.getEventosPerdidos() + " Eventos perdidos");

            panelDetalle.setVisible(true);
        }
    }

    private void cargarListaInicial() {
        listaEmprendimientos.getItems().setAll(dao.listarEmprendimientosResumen());
    }

    private String formatearFecha(Date fecha) {
        if (fecha == null) return "Sin registro";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(fecha);
    }

    private void estilizarTag(Label lbl, String color) {
        lbl.setStyle("-fx-background-color: " + color + "; -fx-text-fill: white; -fx-padding: 3 8 3 8; -fx-background-radius: 10; -fx-font-weight: bold;");
    }

    public void cargarDatos() {
        cargarListaInicial();
        listaEmprendimientos.getSelectionModel().clearSelection();
        panelDetalle.setVisible(false);
    }

    private void exportarReporteActual() {
        if (reporteActual == null) return;

        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Guardar Reporte Operativo");
        fileChooser.setInitialFileName("Reporte_" + reporteActual.getNombre().replace(" ", "_") + ".pdf");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("PDF Files", "*.pdf"));

        java.io.File file = fileChooser.showSaveDialog(getScene().getWindow());

        if (file != null) {

            Utils.GeneradorPDF generador = new Utils.GeneradorPDF();


            generador.generarReporteOperativo(reporteActual, file.getAbsolutePath());

            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle("Éxito");
            alert.setHeaderText(null);
            alert.setContentText("Reporte PDF generado correctamente.");
            alert.showAndWait();
        }
    }
}