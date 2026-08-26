import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba/auth/presentation/providers/auth_provider.dart';
import 'package:prueba/config/menu/menu_items.dart';
import 'package:prueba/home/presentation/providers/providers.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final user = ref.watch(authProvider).user;
    navDrawerIndex = ref.watch(selectedMenuItemProvider);

    final paddingTop = MediaQuery.of(context).viewPadding.top;
    final hasNotch = paddingTop > 35;

    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        final selectedItem = appMenuItems[value];
        widget.scaffoldKey.currentState?.closeEndDrawer();
        ref.read(selectedMenuItemProvider.notifier).select(value);
        context.push(selectedItem.link);
      },
      children: [
        Padding(padding: EdgeInsets.fromLTRB(28, hasNotch ? 0 : 0, 16, 10)),

        Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 16, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset('assets/img/icon.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mindsave',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Tu espacio de bienestar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(
                    _initialFor(user?.name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name.trim().isNotEmpty == true
                            ? user!.name
                            : 'Mi perfil',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 7),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 2, 16, 10),
          child: Text("HERRAMIENTAS"),
        ),

        ...appMenuItems.map((item) {
          return NavigationDrawerDestination(
            icon: Icon(item.icon),
            label: Text(item.title),
          );
        }),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
          child: Divider(),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
          child: Text("Configuración"),
        ),

        SwitchListTile(
          title: Row(
            children: [
              Icon(
                isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              SizedBox(width: 5),
              Text("Modo oscuro"),
            ],
          ),
          value: isDarkMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).toggleDarkMode();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: const Text("Cerrar sesión"),
          onTap: ref.read(authProvider.notifier).logout,
          horizontalTitleGap: 5,
        ),
      ],
    );
  }

  String _initialFor(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? 'M' : trimmed.characters.first.toUpperCase();
  }
}
