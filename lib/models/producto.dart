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
}

const List<Producto> productos = [
  Producto(
    id: 1,
    nombre: 'Laptop Pro 14',
    descripcion: 'Procesador de 12 núcleos, 16 GB RAM y SSD de 512 GB.',
    precio: 899.99,
    imagen: 'https://picsum.photos/seed/laptop/300/200',
  ),
  Producto(
    id: 2,
    nombre: 'Smartphone X',
    descripcion: 'Pantalla AMOLED de 6.5", cámara de 50 MP y 5G.',
    precio: 499.00,
    imagen: 'https://picsum.photos/seed/phone/300/200',
  ),
  Producto(
    id: 3,
    nombre: 'Audífonos BT',
    descripcion: 'Cancelación de ruido y 30 horas de batería.',
    precio: 79.90,
    imagen: 'https://picsum.photos/seed/audio/300/200',
  ),
  Producto(
    id: 4,
    nombre: 'Smartwatch Fit',
    descripcion: 'Monitor cardíaco, GPS y resistencia al agua.',
    precio: 129.50,
    imagen: 'https://picsum.photos/seed/watch/300/200',
  ),
  Producto(
    id: 5,
    nombre: 'Monitor 27"',
    descripcion: 'Resolución 2K a 144 Hz para trabajo y juegos.',
    precio: 259.00,
    imagen: 'https://picsum.photos/seed/monitor/300/200',
  ),
];
