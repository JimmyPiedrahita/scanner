import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para el portapapeles
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Colors.blueAccent),
      ),
      home: const ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  // Controlador del scanner
  final MobileScannerController controller = MobileScannerController();
  
  // Variables de Estado
  bool _isScanning = true; // Controla si mostramos cámara o resultados
  String _scanType = ""; // 'WIFI', 'TEXT'
  
  // Datos para WiFi
  String _wifiSSID = "";
  String _wifiPassword = "";
  
  // Datos para Texto
  String _textContent = "";

  // Lógica principal al detectar un código
  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return; // Si ya estamos mostrando un resultado, ignorar

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final code = barcode.rawValue!;
        
        // 1. CASO WEB: Abrir directo y seguir escaneando (o pausar si prefieres)
        if (code.startsWith("http://") || code.startsWith("https://")) {
           _launchWeb(code);
           // Detenemos procesamiento momentáneo para no abrir el link 5 veces seguidas
           setState(() => _isScanning = false); 
           // Volvemos a activar el scanner tras 2 segundos por si el usuario vuelve
           Future.delayed(const Duration(seconds: 2), () {
             if (mounted) setState(() => _isScanning = true);
           });
           return; 
        }

        // 2. CASO WIFI: Mostrar pantalla de info
        if (code.startsWith("WIFI:")) {
          _parseWifiAndShow(code);
          return;
        }

        // 3. CASO TEXTO/OTRO: Mostrar pantalla de info
        setState(() {
          _scanType = "TEXT";
          _textContent = code;
          _isScanning = false; // Cambiamos la vista a "Resultado"
        });
        return;
      }
    }
  }

  void _launchWeb(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _parseWifiAndShow(String wifiString) {
    // Parser simple para WIFI:S:Nombre;T:WPA;P:Password;;
    final ssid = _getValue(wifiString, "S:");
    final password = _getValue(wifiString, "P:") ?? "Sin contraseña";
    
    setState(() {
      _scanType = "WIFI";
      _wifiSSID = ssid ?? "Red Desconocida";
      _wifiPassword = password;
      _isScanning = false; // Cambiamos la vista a "Resultado"
    });
  }

  String? _getValue(String source, String key) {
    final startIndex = source.indexOf(key);
    if (startIndex == -1) return null;
    final valueStart = startIndex + key.length;
    final endIndex = source.indexOf(";", valueStart);
    if (endIndex == -1) return null;
    return source.substring(valueStart, endIndex);
  }

  // Volver a escanear
  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _wifiSSID = "";
      _wifiPassword = "";
      _textContent = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Si _isScanning es true mostramos CAMARA, si no, mostramos RESULTADO
      body: _isScanning ? _buildCameraView() : _buildResultView(),
    );
  }

  // VISTA 1: La Cámara
  Widget _buildCameraView() {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _handleBarcode,
        ),
        // Marco decorativo
        Center(
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Positioned(
          bottom: 60, left: 0, right: 0,
          child: Text(
            "Escanea un código QR",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  // VISTA 2: El Resultado (WiFi o Texto)
  Widget _buildResultView() {
    bool isWifi = _scanType == "WIFI";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono Grande
          Icon(
            isWifi ? Icons.wifi : Icons.text_fields,
            size: 80,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 30),
          
          // Título
          Text(
            isWifi ? "Red WiFi Detectada" : "Texto Detectado",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 30),

          // CONTENIDO WIFI
          if (isWifi) ...[
             _infoCard("Nombre de Red (SSID)", _wifiSSID),
             const SizedBox(height: 20),
             _infoCard("Contraseña", _wifiPassword),
             const SizedBox(height: 30),
             
             // Botón Copiar Contraseña
             ElevatedButton.icon(
               onPressed: () {
                 Clipboard.setData(ClipboardData(text: _wifiPassword));
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("¡Contraseña copiada!")),
                 );
               },
               icon: const Icon(Icons.copy, color: Colors.black),
               label: const Text("Copiar Contraseña", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
               ),
             ),
          ] 
          // CONTENIDO TEXTO
          else ...[
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.grey[900],
                 borderRadius: BorderRadius.circular(10),
                 border: Border.all(color: Colors.grey[700]!),
               ),
               child: Text(
                 _textContent,
                 style: const TextStyle(fontSize: 16, color: Colors.white70),
                 textAlign: TextAlign.center,
               ),
             ),
             const SizedBox(height: 20),
             // Botón Copiar Texto
             TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _textContent));
                  ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Texto copiado")),
                 );
                },
                icon: const Icon(Icons.copy, color: Colors.white54),
                label: const Text("Copiar Texto", style: TextStyle(color: Colors.white54)),
             )
          ],

          const Spacer(),

          // BOTÓN VOLVER A ESCANEAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetScanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("ESCANEAR DE NUEVO", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar datos bonitos
  Widget _infoCard(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }
}