import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

/// Cuerpo estándar de una pantalla: desplazable (reflujo, WCAG 1.4.10),
/// con márgenes seguros y un ancho máximo para que las líneas de texto no
/// sean demasiado largas en tablets o en horizontal.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.children});

  final List<Widget> children;

  /// Ancho máximo del contenido (≈ 70-80 caracteres a 18 sp).
  static const double maxContentWidth = 720;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Coloca los hijos en cuadrícula de hasta [columns] columnas, según el ancho
/// disponible ([minColumnWidth] por columna), o en una sola si el texto está
/// ampliado o la pantalla es estrecha. El orden de foco es fila por fila,
/// igual que el orden visual.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.columns = 2});

  final List<Widget> children;

  /// Número máximo de columnas (en tablets o en horizontal).
  final int columns;

  static const double minColumnWidth = 150;

  /// `true` si con este ancho y escala de texto hay que usar una sola columna.
  static bool useSingleColumn(BuildContext context, double maxWidth) =>
      MediaQuery.textScalerOf(context).scale(1) >= Dimensions.singleColumnTextScale ||
      maxWidth < Dimensions.singleColumnMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = SizedBox(
          width: Dimensions.spacingBetweenTargets,
          height: Dimensions.spacingBetweenTargets,
        );

        if (useSingleColumn(context, constraints.maxWidth)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, child) in children.indexed) ...[if (i > 0) gap, child],
            ],
          );
        }

        final fit = (constraints.maxWidth / minColumnWidth).floor().clamp(1, columns);
        return Column(
          children: [
            for (var row = 0; row < children.length; row += fit) ...[
              if (row > 0) gap,
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < fit; col++) ...[
                      if (col > 0) gap,
                      Expanded(
                        child: row + col < children.length
                            ? children[row + col]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
