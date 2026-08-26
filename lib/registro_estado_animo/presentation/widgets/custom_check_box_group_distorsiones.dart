import 'package:flutter/material.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

class CustomCheckBoxGroupDistorsiones extends StatefulWidget {
  const CustomCheckBoxGroupDistorsiones({
    super.key,
    required this.title,
    required this.pensamiento,
  });

  final String title;
  final Pensamiento pensamiento;

  @override
  State<CustomCheckBoxGroupDistorsiones> createState() =>
      _CustomCheckBoxGroupDistorsionesState();
}

class _CustomCheckBoxGroupDistorsionesState
    extends State<CustomCheckBoxGroupDistorsiones> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedCount = widget.pensamiento.distorsion
        .where((selected) => selected)
        .length;
    final number = RegExp(r'\d+').firstMatch(widget.title)?.group(0) ?? '1';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          widget.pensamiento.pensamientoNegativo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          '$selectedCount distorsión${selectedCount == 1 ? '' : 'es'} identificada${selectedCount == 1 ? '' : 's'}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: selectedCount > 0 ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
        children: [
          Divider(color: colors.outlineVariant.withAlpha(120)),
          for (
            var index = 0;
            index < Pensamiento.listaDistorsiones.length;
            index++
          )
            CheckboxListTile(
              value: widget.pensamiento.distorsion[index],
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(Pensamiento.listaDistorsiones[index]),
              subtitle: widget.pensamiento.distorsion[index]
                  ? Text(
                      Pensamiento.detalleListaDistorsiones[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onChanged: (value) {
                setState(() {
                  widget.pensamiento.distorsion[index] = value ?? false;
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 2),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_alt_outlined,
                  size: 19,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Creencia inicial',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${widget.pensamiento.porcentajeCreenciaAntes}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
