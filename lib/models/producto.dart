/// Modelo de datos de un producto del catálogo de TiendaTec.
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
  });

  /// Crea un Producto a partir de un mapa JSON (lo que llega de internet o de la caché).
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'] as String,
    );
  }

  /// Convierte el Producto a un mapa JSON (para guardarlo en la caché).
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'imagen': imagen,
  };
}
