/// Modelo de datos de un producto del catálogo de TiendaTec.
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen; // URL (API) o ruta de asset
  final String categoria;
  final double calificacion; // rating de 0 a 5

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    this.categoria = 'General',
    this.calificacion = 0,
  });

  /// true si la imagen viene de internet (API) y no de los assets.
  bool get imagenEsRemota => imagen.startsWith('http');

  /// Mapea un producto de la API pública DummyJSON (claves en inglés)
  /// al modelo de TiendaTec. Programación defensiva: si un campo llega
  /// null o con otro tipo, se usa un valor seguro y la app no se cae.
  factory Producto.fromApiJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['title'] as String? ?? 'Producto sin nombre',
      descripcion: json['description'] as String? ?? 'Sin descripción',
      precio: (json['price'] as num?)?.toDouble() ?? 0,
      imagen: json['thumbnail'] as String? ?? '',
      categoria: json['category'] as String? ?? 'General',
      calificacion: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Crea un Producto desde el formato interno (el que se guarda en la caché).
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? 'Producto sin nombre',
      descripcion: json['descripcion'] as String? ?? 'Sin descripción',
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
      imagen: json['imagen'] as String? ?? '',
      categoria: json['categoria'] as String? ?? 'General',
      calificacion: (json['calificacion'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Convierte el Producto a un mapa JSON (para guardarlo en la caché).
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'imagen': imagen,
    'categoria': categoria,
    'calificacion': calificacion,
  };
}
