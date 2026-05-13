# ATRIUM — Sistema de Gestión para Centro de Emprendimiento

> Aplicación de escritorio en Java que centraliza la operación integral de un centro de emprendimiento: registro de eventos, seguimiento de emprendimientos, mentorías y generación de reportes analíticos exportables a PDF.

---

## Flujo del Proyecto

```
Excel (.xlsx) → LectorExcel → JDBC → PostgreSQL (Stored Functions)
                                                         ↓
JavaFX (UI) ←→ DAO Layer ←→ JDBC ←→ PostgreSQL → iText PDF Generator
```

---

## Stack Tecnológico

| Capa / Módulo        | Tecnología                              |
|----------------------|-----------------------------------------|
| Lenguaje             | Java 17+                                |
| Interfaz gráfica     | JavaFX + CSS externo (`estilos.css`)    |
| Base de datos        | PostgreSQL 16                           |
| Conectividad BD      | JDBC — `postgresql-42.7.8.jar`          |
| Generación de PDFs   | iText — `itextpdf-5.5.13.2.jar`         |
| Lectura de Excel     | Apache POI — `XSSFWorkbook`             |
| Patrón de diseño     | DAO + DTO                               |
| Lógica de negocio BD | Stored Functions + Transacciones ACID   |

---

## Estructura Principal

**Paquete `BaseDatos` (capa DAO):**
`ConexionDB`, `EventoDAO`, `ReporteDAO`, `StaffDAO`, `StaffEventoDAO`, `EmprendimientoDAO`, `EmprendimientoEventoDAO`, `LugarDAO`

**Paquete `Modelo.Esquema` (entidades):**
`Emprendimiento`, `Evento`, `Actividad`, `Mentoria`, `Miembro`, `Staff`, `Mentor`, `Expositor`, `Persona`, `Facultad`, `Carrera`, `Lugar`, `EstudioMercado`, `ParticipacionMiembro`, `StaffEvento`, `EmprendimientoEvento`

**Paquete `Modelo.DTOs`:**
`ReporteEmprendimientoDTO`, `ReporteOperativoDTO`

**Paquete `Utils`:**
`GeneradorPDF`, `LectorExcel`

**Paquete `InterfazGrafica`:**
`AtriumApp` (entry point), `Launcher`

- Módulos: `ModuloEventos`, `ModuloReportes`, `ModuloCargaExcel`
- Vistas formulario: `VistaDatosGenerales`, `VistaEmprendimientos`, `VistaStaff`, `VistaBienvenida`
- Vistas reportes: `VistaReporteIndividual`, `VistaReporteOperativo`

**Base de datos `centro_emprendimiento`:**
Funciones almacenadas: `fn_crear_evento_seguro`, `fn_emprendimiento_evento`, `fn_facultad`, `fn_lugar`, `fn_reporte1_por_emprendimiento`, `fn_reporte2_estado_operativo_por_emprendimiento`

---

## Modelo de Datos

La base de datos está normalizada en **Tercera Forma Normal (3FN)**, separando entidades por dominio:

**Analíticas:** `EstudioMercado` — factibilidad económica, factibilidad técnica, ventas.

**Académicas:** `PerfilAcademico`, `Carrera`, `Facultad` — vinculadas a miembros y líderes mediante GPA y matrícula.

**Operativas:** `Evento`, `Actividad`, `Mentoria` — con tablas intermedias `EmprendimientoEvento`, `StaffEvento`, `EmprendimientoActividad` y `ParticipacionMiembro` para relaciones N:M.

---

## Características

| Módulo / Feature              | Descripción                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| Gestión de eventos            | Formulario multipestañas: datos generales, emprendimientos participantes, staff asignado con validación de horas |
| Seguimiento de emprendimientos | Sector, nivel de madurez, modelo de negocio, ventas, presupuesto, redes sociales |
| Reporte de rendimiento        | Nivel de madurez, factibilidad, estadísticas (eventos / actividades / mentorías), perfil del líder |
| Reporte operativo             | Estado de actividad, fechas de última interacción, inasistencias, distribución de horas del equipo |
| Exportación PDF               | Ambos reportes generan documentos estructurados vía iText con logo y tablas formateadas |
| Carga masiva (dos fases)      | Fase 1: estructura base (Facultades, Lugares). Fase 2: datos adicionales sin sobrescritura |
| Transacciones atómicas        | COMMIT / ROLLBACK en creación de eventos y carga masiva completa            |

---

## Ejecución

### Prerrequisitos

- JDK 17+
- JavaFX SDK 17+ ([Gluon](https://gluonhq.com/products/javafx/))
- PostgreSQL 16
- Librerías en `lib/`: `itextpdf-5.5.13.2.jar`, `postgresql-42.7.8.jar`, archivos Apache POI

### Base de datos

```bash
# Crear la base de datos
psql -U postgres -c "CREATE DATABASE centro_emprendimiento;"

# Aplicar esquema DDL y funciones almacenadas
psql -U postgres -d centro_emprendimiento -f database/schema.sql
psql -U postgres -d centro_emprendimiento -f database/functions.sql
```

Configurar credenciales en `src/main/java/BaseDatos/ConexionDB.java`:

```java
private static final String URL  = "jdbc:postgresql://localhost:5432/centro_emprendimiento";
private static final String USER = "postgres";
private static final String PASS = "tu_contraseña";
```

### Aplicación (IntelliJ IDEA)

```bash
# 1. Agregar JARs al classpath
#    File > Project Structure > Libraries > + > Java
#    Seleccionar: lib/itextpdf-5.5.13.2.jar  lib/postgresql-42.7.8.jar  lib/poi-ooxml-*.jar

# 2. Configurar VM Options en Run Configuration
#    --module-path /ruta/a/javafx-sdk/lib --add-modules javafx.controls,javafx.fxml

# 3. Main class: InterfazGrafica.Launcher
```

### Aplicación (terminal)

```bash
# Ejecutar con JavaFX en el module path
java --module-path /ruta/a/javafx-sdk/lib \
     --add-modules javafx.controls,javafx.fxml \
     -cp "out/production/atrium:lib/*" \
     InterfazGrafica.Launcher
```

---

## Capturas de Pantalla

**Pantalla de bienvenida**

![Bienvenida](docs/screenshots/bienvenida.png)

**Módulo: Gestión de Eventos**

![Datos generales](docs/screenshots/evento_datos_generales.png)
![Emprendimientos participantes](docs/screenshots/evento_emprendimientos.png)
![Staff adicional](docs/screenshots/evento_staff.png)

**Módulo: Reportes**

![Reporte de rendimiento individual](docs/screenshots/reporte_individual.png)
![Reporte operativo](docs/screenshots/reporte_operativo.png)
![PDF generado](docs/screenshots/reporte_pdf.png)

**Módulo: Carga de Datos**

![Carga Excel](docs/screenshots/carga_excel.png)

---

## Integrantes

| Integrante                         | Rol / Módulo                                                             |
|------------------------------------|--------------------------------------------------------------------------|
| Daniel Sebastián Gómez             | Diccionario de datos, modelo relacional, bitácora de base de datos       |
| Karel González                     | Normalización (3FN), lógica de lectura y carga masiva desde Excel        |
| Justin Soledispa                   | Arquitectura Java, UI/UX, conexión BD, generación de PDFs, transacciones |
| Juan Diego Sotomayor               | Modelo relacional, diseño de interfaz, implementación de reportes        |

---

Proyecto académico — Base de Datos 1 · Universidad Espíritu Santo (UEES) · 2025
