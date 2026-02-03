# QR Scanner Pro 📱

Una aplicación moderna y eficiente construida con **Flutter** para escanear y gestionar códigos QR de forma inteligente. Simplifica la conexión a redes WiFi, la navegación web y la captura de texto.

## 🚀 Características Principales

Esta aplicación no es solo un lector, interpreta los datos para ofrecerte acciones rápidas:

*   **⚡ Escaneo en Tiempo Real**: Detección rápida y fluida utilizando la cámara del dispositivo.
*   **🌐 Apertura Automática de Enlaces**: Detecta URLs (`http`/`https`) y las abre automáticamente en tu navegador predeterminado.
*   **📶 Conexión WiFi Simplificada**:
    *   Reconoce códigos QR de configuración WiFi.
    *   Extrae y muestra el **SSID** (Nombre de red) y la **Contraseña**.
    *   Incluye un botón rápido para **copiar la contraseña** al portapapeles.
*   **📄 Modo Texto**:
    *   Muestra el contenido de cualquier otro código QR.
    *   Permite copiar el texto detectado con un solo toque.
*   **🎨 Diseño Dark Mode**: Interfaz elegante y oscura para reducir la fatiga visual y ahorrar batería.

## 🛠️ Tecnologías Utilizadas

El proyecto está construido sobre el ecosistema de Flutter y utiliza paquetes robustos:

*   **[Flutter](https://flutter.dev)**: Framework UI.
*   **[mobile_scanner](https://pub.dev/packages/mobile_scanner)**: Para el acceso a cámara y detección de códigos de alto rendimiento.
*   **[url_launcher](https://pub.dev/packages/url_launcher)**: Para la gestión y apertura de enlaces externos.
*   **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)**: Para gestionar los iconos de la aplicación.

## 🏁 Comenzando

Sigue estos pasos para ejecutar el proyecto en tu entorno local.

### Prerrequisitos

*   Flutter SDK instalado (versión recomendada: 3.10.0 o superior).
*   Dispositivo Android/iOS configurado o emulador.

### Instalación

1.  **Clona el repositorio**
    ```bash
    git clone https://github.com/JimmyPiedrahita/scanner.git
    cd scanner
    ```

2.  **Instala las dependencias**
    ```bash
    flutter pub get
    ```

3.  **Ejecuta la aplicación**
    ```bash
    flutter run
    ```

## 📂 Estructura del Código

La lógica principal se encuentra centralizada para facilitar el mantenimiento:

*   `lib/main.dart`: Contiene toda la lógica de la aplicación, incluyendo:
    *   `MainApp`: Configuración del tema y rutas.
    *   `ScannerPage`: Gestión de la cámara y procesamiento de códigos.
    *   `_handleBarcode`: Lógica inteligente para diferenciar entre Web, WiFi y Texto.