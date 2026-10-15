/// Resultado de ejemplo para la versión de demostración.
///
/// Simula lo que devolverá Gemini con el esquema de ARQUITECTURA.md §4.2
/// para un diagrama de clases UML. Es contenido de datos (no texto de la
/// interfaz), por eso no está en el ARB.
abstract final class SampleResult {
  static const resumen =
      'Diagrama de clases UML con 4 clases que modela un sistema de pedidos. '
      'Un usuario puede hacer muchos pedidos y cada pedido contiene uno o más productos.';

  static const regiones = [
    (
      'Parte superior izquierda',
      'La clase Persona, abstracta, tiene los atributos privados nombre y correo, de tipo String.',
    ),
    (
      'Parte superior derecha',
      'La clase Usuario hereda de Persona. Tiene el atributo privado id, de tipo entero, '
          'y los métodos públicos registrar y login.',
    ),
    (
      'Parte inferior izquierda',
      'La clase Pedido tiene los atributos fecha y total. Se relaciona con Usuario: '
          'un usuario tiene muchos pedidos, de uno a muchos.',
    ),
    (
      'Parte inferior derecha',
      'La clase Producto tiene nombre y precio. Un pedido contiene uno o más productos, '
          'por composición. Esta zona de la imagen está borrosa.',
    ),
  ];

  static const nodos = 4;
  static const relaciones = 3;

  static const advertencia = 'Confianza media. La parte inferior derecha de la imagen está borrosa.';

  static const textoDetectado = ['Sistema de pedidos', 'versión 2'];

  static const lenguajeCodigo = 'Java';
  static const codigo = [
    'public class Usuario extends Persona {',
    '    private int id;',
    '    public boolean login(String clave) { … }',
    '}',
  ];

  static const conceptosClave = ['Herencia', 'Multiplicidad', 'Composición', 'Clase abstracta'];
}
