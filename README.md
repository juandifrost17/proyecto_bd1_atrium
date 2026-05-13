# ATRIUM — Sistema de Gestión para Centro de Emprendimiento

> Aplicación de escritorio en Java que centraliza la operación integral de un centro de emprendimiento: registro de eventos, seguimiento de emprendimientos, mentorías y generación de reportes analíticos.

---

## Descripción

ATRIUM permite gestionar de forma centralizada los eventos, emprendimientos y mentorías de un centro universitario. Desde un formulario multipestañas se registran eventos con sus participantes y staff asignado; los reportes analíticos —exportables a PDF— muestran el rendimiento individual de cada emprendimiento y su estado operativo general.

---

## Flujo del Proyecto

```
Excel (.xlsx) → LectorExcel → JDBC → PostgreSQL → JavaFX UI
                                          ↓
                               iText PDF Generator
```

---

## Stack Tecnológico

| Capa / Módulo | Tecnología |
|---------------|------------|
| Lenguaje | Java 17+ |
| Interfaz gráfica | JavaFX + CSS externo |
| Base de datos | PostgreSQL 16 |
| Conectividad BD | JDBC — `postgresql-42.7.8.jar` |
| Generación de PDFs | iText — `itextpdf-5.5.13.2.jar` |
| Lectura de Excel | Apache POI — `XSSFWorkbook` |
| Patrón de diseño | DAO + DTO · Stored Functions · Transacciones ACID |

---

## Arquitectura

El sistema sigue el patrón **DAO + DTO** con lógica de negocio encapsulada en stored functions de PostgreSQL. La base de datos está normalizada en **3FN**, separando dominios en tres grupos:

- **Operativo:** `Evento`, `Actividad`, `Mentoria` con relaciones N:M vía tablas intermedias
- **Analítico:** `EstudioMercado` — factibilidad económica, técnica y ventas
- **Académico:** `PerfilAcademico`, `Carrera`, `Facultad` vinculadas a miembros y líderes

---

## Características Principales

| Módulo | Descripción |
|--------|-------------|
| Gestión de eventos | Formulario multipestañas: datos generales, emprendimientos participantes, staff con validación de horas |
| Seguimiento | Sector, madurez, modelo de negocio, ventas, presupuesto y redes sociales por emprendimiento |
| Reporte de rendimiento | Factibilidad, estadísticas de participación y perfil del líder exportable a PDF |
| Reporte operativo | Estado de actividad, fechas de última interacción, inasistencias y distribución de horas |
| Carga masiva | Dos fases desde Excel: estructura base (Facultades, Lugares) y datos adicionales sin sobrescritura |

---

## Capturas de Pantalla

**Pantalla de bienvenida**
![Bienvenida](docs/screenshots/bienvenida.png)

**Módulo: Gestión de Eventos**
![Datos generales](docs/screenshots/evento_datos_generales.png)
![Emprendimientos participantes](docs/screenshots/evento_emprendimientos.png)
![Staff adicional](docs/screenshots/evento_staff.png)

**Módulo: Reportes**
![Reporte individual](docs/screenshots/reporte_individual.png)
![Reporte operativo](docs/screenshots/reporte_operativo.png)
![PDF generado](docs/screenshots/reporte_pdf.png)

**Módulo: Carga de Datos**
![Carga Excel](docs/screenshots/carga_excel.png)

---

## Ejecución

### Prerrequisitos
- JDK 17+ y JavaFX SDK 17+ ([Gluon](https://gluonhq.com/products/javafx/))
- PostgreSQL 16
- JARs en `lib/`: `itextpdf-5.5.13.2.jar`, `postgresql-42.7.8.jar`, Apache POI

### Base de datos
```bash
psql -U postgres -c "CREATE DATABASE centro_emprendimiento;"
psql -U postgres -d centro_emprendimiento -f database/schema.sql
psql -U postgres -d centro_emprendimiento -f database/functions.sql
```

Configurar credenciales en `src/main/java/BaseDatos/ConexionDB.java`:
```java
private static final String URL  = "jdbc:postgresql://localhost:5432/centro_emprendimiento";
private static final String USER = "postgres";
private static final String PASS = "tu_contraseña";
```

### Levantar la aplicación
```bash
# Desde terminal
java --module-path /ruta/a/javafx-sdk/lib \
     --add-modules javafx.controls,javafx.fxml \
     -cp "out/production/atrium:lib/*" \
     InterfazGrafica.Launcher
```

> **IntelliJ IDEA:** agregar JARs en *Project Structure > Libraries*, configurar VM Options con `--module-path` y `--add-modules`, y establecer como main class `InterfazGrafica.Launcher`.

---

## Integrantes

| Integrante | Rol / Módulo |
|------------|--------------|
| Daniel Sebastián Gómez | Diccionario de datos, modelo relacional, bitácora de BD |
| Karel González | Normalización 3FN, lógica de carga masiva desde Excel |
| Justin Soledispa | Arquitectura Java, UI/UX, conexión BD, PDFs, transacciones |
| Juan Diego Sotomayor | Modelo relacional, diseño de interfaz, implementación de reportes |

---

*Proyecto académico — Base de Datos 1 · Universidad Espíritu Santo (UEES) · 2025*
