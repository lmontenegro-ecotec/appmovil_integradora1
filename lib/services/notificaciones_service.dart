import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio nativo de notificaciones locales (desacoplado de la interfaz).
/// Configura el canal nativo de Android y los ajustes de iOS (Darwin),
/// y muestra alertas ante eventos clave del sistema.
class NotificacionesService {
  NotificacionesService._();

  /// Única instancia para toda la app (patrón Singleton).
  static final NotificacionesService instancia = NotificacionesService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inicializado = false;
  int _siguienteId = 0;

  /// Canal nativo de Android (Android 8+ exige un canal para notificar).
  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'alertas_tiendatec',
    'Alertas TiendaTec',
    description: 'Avisos de conexión, favoritos y perfil',
    importance: Importance.high,
  );

  /// Se llama una sola vez al iniciar la app.
  Future<void> inicializar() async {
    try {
      const ajustesAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ajustesIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: ajustesAndroid,
          iOS: ajustesIOS,
        ),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_canal);

      _inicializado = true;
      debugPrint('Notificaciones: servicio inicializado');
    } catch (e) {
      debugPrint('Notificaciones: no se pudo inicializar -> $e');
    }
  }

  /// Android 13+ exige pedir permiso para mostrar notificaciones.
  Future<void> solicitarPermiso() async {
    try {
      final concedido = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      debugPrint('Notificaciones: permiso concedido = $concedido');
    } catch (e) {
      debugPrint('Notificaciones: error al pedir permiso -> $e');
    }
  }

  /// Muestra una notificación local inmediata.
  Future<void> mostrar(String titulo, String mensaje) async {
    if (!_inicializado) return;
    try {
      await _plugin.show(
        id: _siguienteId++,
        title: titulo,
        body: mensaje,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _canal.id,
            _canal.name,
            channelDescription: _canal.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      debugPrint('Notificación enviada: $titulo');
    } catch (e) {
      debugPrint('Notificaciones: no se pudo mostrar -> $e');
    }
  }
}
