package InterfazGrafica.VistasFormulario;

import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import java.io.InputStream;

public class VistaBienvenida extends VBox {

    public VistaBienvenida() {

        this.setAlignment(Pos.CENTER);
        this.setSpacing(30);

        this.setStyle("-fx-background-color: #f5f6fa;");

        construirInterfaz();
    }

    private void construirInterfaz() {

        Label lblTitulo = new Label("¡Bienvenido a ATRIUM!");

        lblTitulo.setStyle("-fx-font-size: 36px; -fx-font-weight: bold; -fx-text-fill: #000b3d;");

        Label lblSubtitulo = new Label("Tu sistema de gestión de emprendimientos.");
        lblSubtitulo.setStyle("-fx-font-size: 18px; -fx-text-fill: #7f8c8d;");


        ImageView gifView = new ImageView();
        try {

            InputStream stream = getClass().getResourceAsStream("/imagenes/bienvenida.png");

            if (stream != null) {
                Image gif = new Image(stream);
                gifView.setImage(gif);


                gifView.setFitWidth(450);
                gifView.setFitHeight(450);
                 gifView.setPreserveRatio(true);
            } else {
                System.out.println(" No se encontró el PNG de bienvenida");
                lblSubtitulo.setText("(No pudimos cargar el PNG de bienvenida)");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }


        this.getChildren().addAll(lblTitulo, lblSubtitulo, gifView);
    }
}