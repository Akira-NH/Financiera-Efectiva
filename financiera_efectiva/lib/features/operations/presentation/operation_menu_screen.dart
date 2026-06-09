import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../domain/entities/operation_contact.dart';

class OperationMenuScreen extends StatefulWidget {
  const OperationMenuScreen({super.key});

  @override
  State<OperationMenuScreen> createState() => _OperationMenuScreenState();
}

class _OperationMenuScreenState extends State<OperationMenuScreen> {
  final _searchController = TextEditingController();
  Future<List<OperationContact>>? _searchFuture;
  late Future<List<OperationContact>> _quickAccessFuture;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _quickAccessFuture =
        FinancialFirestoreService.instance.getQuickAccessContacts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshQuickAccess() {
    setState(() {
      _quickAccessFuture =
          FinancialFirestoreService.instance.getQuickAccessContacts();
    });
  }

  void _searchContacts(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchFuture =
            FinancialFirestoreService.instance.searchContactsByName(value);
      });
    });
  }

  Future<void> _addQuickAccess(OperationContact contact) async {
    try {
      await FinancialFirestoreService.instance.addQuickAccessContact(contact);
      if (!mounted) return;
      _refreshQuickAccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.fullName} agregado a accesos rápidos.')),
      );
    } catch (error) {
      _showError(error, 'No se pudo agregar el contacto.');
    }
  }

  Future<void> _removeQuickAccess(OperationContact contact) async {
    try {
      await FinancialFirestoreService.instance.removeQuickAccessContact(
        contact.id,
      );
      if (!mounted) return;
      _refreshQuickAccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.fullName} eliminado.')),
      );
    } catch (error) {
      _showError(error, 'No se pudo eliminar el contacto.');
    }
  }

  void _openTransfer(OperationContact contact) {
    Navigator.pushNamed(context, RouteNames.transfer, arguments: contact);
  }

  void _showError(Object error, String fallback) {
    if (!mounted) return;
    final message = error is AppException ? error.message : fallback;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Operaciones', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _QuickAccessSection(
          future: _quickAccessFuture,
          onTap: _openTransfer,
          onRemove: _removeQuickAccess,
        ),
        const SizedBox(height: 20),
        Text('Buscar contacto', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          onChanged: _searchContacts,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Nombre del contacto',
            hintText: 'Escribe al menos 2 letras',
          ),
        ),
        const SizedBox(height: 12),
        _SearchResults(
          future: _searchFuture,
          onTransfer: _openTransfer,
          onAddQuickAccess: _addQuickAccess,
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, RouteNames.payment),
          icon: const Icon(Icons.payments),
          label: const Text('Pagar servicio'),
        ),
      ],
    );
  }
}

class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection({
    required this.future,
    required this.onTap,
    required this.onRemove,
  });

  final Future<List<OperationContact>> future;
  final ValueChanged<OperationContact> onTap;
  final ValueChanged<OperationContact> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos rápidos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<OperationContact>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('No se pudieron cargar los accesos rápidos.');
            }
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 88,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final contacts = snapshot.data!;
            if (contacts.isEmpty) {
              return const Text('Aún no tienes contactos frecuentes.');
            }

            return SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: contacts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return _QuickAccessContact(
                    contact: contact,
                    onTap: () => onTap(contact),
                    onRemove: () => onRemove(contact),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAccessContact extends StatelessWidget {
  const _QuickAccessContact({
    required this.contact,
    required this.onTap,
    required this.onRemove,
  });

  final OperationContact contact;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: contact.photoUrl == null
                      ? null
                      : NetworkImage(contact.photoUrl!),
                  child: contact.photoUrl == null
                      ? Text(
                          contact.initials,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: -8,
                top: -8,
                child: IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  tooltip: 'Eliminar',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contact.fullName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.future,
    required this.onTransfer,
    required this.onAddQuickAccess,
  });

  final Future<List<OperationContact>>? future;
  final ValueChanged<OperationContact> onTransfer;
  final ValueChanged<OperationContact> onAddQuickAccess;

  @override
  Widget build(BuildContext context) {
    final searchFuture = future;
    if (searchFuture == null) {
      return const Text('Busca un contacto registrado para transferir.');
    }

    return FutureBuilder<List<OperationContact>>(
      future: searchFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('No se pudo realizar la búsqueda.');
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final contacts = snapshot.data!;
        if (contacts.isEmpty) {
          return const Text('No se encontraron contactos registrados.');
        }

        return Column(
          children: contacts.map((contact) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(contact.initials)),
              title: Text(contact.fullName),
              subtitle: Text(contact.email),
              onTap: () => onTransfer(contact),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Agregar a accesos rápidos',
                    onPressed: () => onAddQuickAccess(contact),
                    icon: const Icon(Icons.star_border),
                  ),
                  IconButton.filled(
                    tooltip: 'Transferir',
                    onPressed: () => onTransfer(contact),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
