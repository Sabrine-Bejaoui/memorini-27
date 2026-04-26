import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../models/product_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  bool _isAdmin = false;
  bool _saving = false;
  String _section = 'dashboard';
  String _userSearch = '';
  List<ProductModel> _products = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _users = [];
  int? _selectedMonth = DateTime.now().month;
  int? _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final isAdmin = await ApiService.isAdmin();
      if (!mounted) return;
      if (!isAdmin) {
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      final results = await Future.wait([
        ApiService.getProducts(),
        ApiService.getAllOrders(),
        ApiService.getAllUsers(),
      ]);
      if (!mounted) return;
      setState(() {
        _isAdmin = true;
        _products = results[0] as List<ProductModel>;
        _orders = results[1] as List<Map<String, dynamic>>;
        _users = results[2] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
  }

  Future<void> _toggleUserRole(Map<String, dynamic> user) async {
    final current = user['role']?.toString() ?? 'client';
    final next = current == 'admin' ? 'client' : 'admin';
    try {
      await ApiService.updateUserRole(userId: user['id'] as int, role: next);
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
    try {
      await ApiService.updateUserStatus(
        userId: user['id'] as int,
        isActive: !(user['is_active'] as bool? ?? true),
      );
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _setOrderStatus(int orderId, String status) async {
    try {
      await ApiService.updateOrderStatus(orderId: orderId, status: status);
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      await ApiService.deleteOrder(orderId);
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _openProductEditor({ProductModel? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final categoryController = TextEditingController(text: product?.category ?? 'Standard');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product != null ? product.price.toStringAsFixed(2) : '');
    final imageController = TextEditingController(text: product?.mainImage ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(product == null ? 'Nouveau produit' : 'Modifier le produit'),
              content: SizedBox(
                width: 560,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(labelText: 'Catégorie'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Prix'),
                        validator: (value) => double.tryParse(value ?? '') == null ? 'Prix invalide' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: imageController,
                        decoration: const InputDecoration(labelText: 'URL image'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => _saving = true);
                          try {
                            if (product == null) {
                              await ApiService.createProduct(
                                name: nameController.text.trim(),
                                category: categoryController.text.trim(),
                                description: descriptionController.text.trim(),
                                price: double.parse(priceController.text.trim()),
                                mainImage: imageController.text.trim(),
                              );
                            } else {
                              await ApiService.updateProduct(
                                productId: product.id,
                                name: nameController.text.trim(),
                                category: categoryController.text.trim(),
                                description: descriptionController.text.trim(),
                                price: double.parse(priceController.text.trim()),
                                mainImage: imageController.text.trim(),
                              );
                            }
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            await _loadData();
                          } catch (e) {
                            _showError(e);
                          } finally {
                            if (mounted) setDialogState(() => _saving = false);
                          }
                        },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Confirmer la suppression de "${product.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteProduct(product.id);
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer utilisateur'),
        content: Text('Supprimer ${user['full_name'] ?? 'cet utilisateur'} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteUser(user['id'] as int);
      await _loadData();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _openUserEditor(Map<String, dynamic> user) async {
    final nameController = TextEditingController(text: user['full_name']?.toString() ?? '');
    final emailController = TextEditingController(text: user['email']?.toString() ?? '');
    final phoneController = TextEditingController(text: user['phone']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim()) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ApiService.updateUser(
                  userId: user['id'] as int,
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(context).pop();
                await _loadData();
              } catch (e) {
                _showError(e);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUserCreator() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController(text: 'password123');
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créer un utilisateur'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim()) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: (value) => value == null || value.trim().length < 6 ? 'Min 6 caractères' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ApiService.register(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(context).pop();
                await _loadData();
              } catch (e) {
                _showError(e);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_isAdmin) {
      return const Scaffold(body: Center(child: Text('Accès refusé: compte admin requis.')));
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: _buildSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F4EE),
        border: Border(right: BorderSide(color: AppColors.softBorder)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.softBorder))),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Memorini', style: TextStyle(fontSize: 28, color: AppColors.burgundy, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Administration', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
          _sideItem('dashboard', 'Vue d\'ensemble', Icons.grid_view_outlined),
          _sideItem('products', 'Produits', Icons.inventory_2_outlined),
          _sideItem('orders', 'Commandes', Icons.shopping_cart_outlined),
          _sideItem('users', 'Utilisateurs', Icons.groups_2_outlined),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await ApiService.logout();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(42), 
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Déconnexion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(String key, String label, IconData icon) {
    final selected = _section == key;
    return InkWell(
      onTap: () => setState(() => _section = key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE6C5) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.burgundy : AppColors.textDark),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: selected ? AppColors.burgundy : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case 'products':
        return _productsSection();
      case 'orders':
        return _ordersSection();
      case 'users':
        return _usersSection();
      default:
        return _dashboardSection();
    }
  }

  Widget _dashboardSection() {
    final filteredOrders = _orders.where((o) {
      if (o['created_at'] == null) return true;
      final d = DateTime.tryParse(o['created_at'].toString());
      if (d == null) return true;
      if (_selectedYear != null && d.year != _selectedYear) return false;
      if (_selectedMonth != null && d.month != _selectedMonth) return false;
      return true;
    }).toList();

    final filteredUsers = _users.where((u) {
      if (u['created_at'] == null) return true;
      final d = DateTime.tryParse(u['created_at'].toString());
      if (d == null) return true;
      if (_selectedYear != null && d.year != _selectedYear) return false;
      if (_selectedMonth != null && d.month != _selectedMonth) return false;
      return true;
    }).toList();

    final revenue = filteredOrders.fold<double>(0, (sum, o) => sum + (double.tryParse(o['total_price'].toString()) ?? 0));
    final clients = filteredUsers.where((u) => (u['role']?.toString() ?? '') != 'admin').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Espace administrateur', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                const Text(
                  "Vue d'ensemble",
                  style: TextStyle(fontSize: 50, color: AppColors.burgundy, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Row(
              children: [
                _buildDropdown<int?>(
                  value: _selectedMonth,
                  hint: 'Mois',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous les mois')),
                    ...List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateFormat('MMMM', 'fr').format(DateTime(2020, i + 1)).toUpperCase()))),
                  ],
                  onChanged: (val) => setState(() => _selectedMonth = val),
                ),
                const SizedBox(width: 12),
                _buildDropdown<int?>(
                  value: _selectedYear,
                  hint: 'Année',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes les années')),
                    ...List.generate(5, (i) => DropdownMenuItem(value: DateTime.now().year - i, child: Text('${DateTime.now().year - i}'))),
                  ],
                  onChanged: (val) => setState(() => _selectedYear = val),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Statistiques en temps réel de votre boutique', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 32),
        Row(
          children: [
            _metricCard(
              title: 'REVENUS',
              value: '${revenue.toStringAsFixed(2)} DT',
              dark: true,
            ),
            const SizedBox(width: 16),
            _metricCard(title: 'COMMANDES', value: '${filteredOrders.length}'),
            const SizedBox(width: 16),
            _metricCard(title: 'NOUVEAUX CLIENTS', value: '$clients'),
            const SizedBox(width: 16),
            _metricCard(title: 'PRODUITS', value: '${_products.length}'),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({required T value, required String hint, required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.softBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        underline: const SizedBox.shrink(),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _productsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produits', style: TextStyle(fontSize: 56, color: AppColors.burgundy, fontWeight: FontWeight.w700)),
                Text('Gérez votre catalogue', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
            FilledButton.icon(
              onPressed: () => _openProductEditor(),
              style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.burgundy),
              icon: const Icon(Icons.add),
              label: const Text('Nouveau produit'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _containerCard(
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
                columns: const [
                  DataColumn(label: Text('PRODUIT')),
                  DataColumn(label: Text('CATÉGORIE')),
                  DataColumn(label: Text('PRIX')),
                  DataColumn(label: Text('STATUT')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: _products
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    p.mainImage,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 42,
                                      height: 42,
                                      color: AppColors.softBorder,
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 210, child: Text(p.name, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          DataCell(Text(p.category)),
                          DataCell(Text('${p.price.toStringAsFixed(2)} DT')),
                          const DataCell(_StatusChip(label: 'Actif')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(onPressed: () => _openProductEditor(product: p), icon: const Icon(Icons.edit_outlined)),
                                IconButton(
                                  onPressed: () => _deleteProduct(p),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red.shade400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _usersSection() {
    final users = _users.where((u) {
      if (_userSearch.trim().isEmpty) return true;
      final needle = _userSearch.toLowerCase();
      final hay = '${u['full_name'] ?? ''} ${u['phone'] ?? ''}'.toLowerCase();
      return hay.contains(needle);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Utilisateurs', style: TextStyle(fontSize: 56, color: AppColors.burgundy, fontWeight: FontWeight.w700)),
                Text('Gérez les comptes et les rôles administrateurs', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher par nom ou téléphone...'),
                onChanged: (value) => setState(() => _userSearch = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _openUserCreator,
            style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.burgundy),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nouvel utilisateur'),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _containerCard(
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
                columns: const [
                  DataColumn(label: Text('NOM')),
                  DataColumn(label: Text('TÉLÉPHONE')),
                  DataColumn(label: Text('INSCRIT LE')),
                  DataColumn(label: Text('ADMIN')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: users
                    .map(
                      (u) => DataRow(
                        cells: [
                          DataCell(Text(u['full_name']?.toString() ?? '-')),
                          DataCell(Text(u['phone']?.toString() ?? '—')),
                          DataCell(Text(_formatDate(u['created_at']?.toString()))),
                          DataCell(
                            Row(
                              children: [
                                Switch(
                                  value: (u['role']?.toString() ?? 'client') == 'admin',
                                  onChanged: (_) => _toggleUserRole(u),
                                  activeThumbColor: AppColors.burgundy,
                                ),
                                Text((u['role']?.toString() ?? 'client') == 'admin' ? 'Admin' : 'Client'),
                                IconButton(
                                  tooltip: (u['is_active'] as bool? ?? true) ? 'Désactiver' : 'Activer',
                                  onPressed: () => _toggleUserStatus(u),
                                  icon: Icon((u['is_active'] as bool? ?? true) ? Icons.lock_open : Icons.lock),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Modifier',
                                  onPressed: () => _openUserEditor(u),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => _deleteUser(u),
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ordersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Commandes', style: TextStyle(fontSize: 56, color: AppColors.burgundy, fontWeight: FontWeight.w700)),
        const Text('Suivez et mettez à jour les commandes', style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 16),
        Expanded(
          child: _containerCard(
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
                columns: const [
                  DataColumn(label: Text('N°')),
                  DataColumn(label: Text('CLIENT')),
                  DataColumn(label: Text('CONTACT')),
                  DataColumn(label: Text('ADRESSE')),
                  DataColumn(label: Text('PRODUITS')),
                  DataColumn(label: Text('DATE')),
                  DataColumn(label: Text('STATUT')),
                  DataColumn(label: Text('TOTAL')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: _orders
                    .map(
                      (o) => DataRow(
                        cells: [
                          DataCell(Text('#${o['id']}')),
                          DataCell(Text(o['full_name']?.toString() ?? '-')),
                          DataCell(Text([o['phone1'], o['phone2']].whereType<String>().where((e) => e.isNotEmpty).join(' / '))),
                          DataCell(SizedBox(width: 180, child: Text('${o['address'] ?? '-'} - ${o['city'] ?? '-'}'))),
                          DataCell(SizedBox(width: 220, child: Text(_formatItems(o['items']?.toString())))),
                          DataCell(Text(_formatDate(o['created_at']?.toString()))),
                          DataCell(_statusDropdown(o)),
                          DataCell(Text('${o['total_price']} DT')),
                          DataCell(
                            IconButton(
                              tooltip: 'Supprimer',
                              onPressed: () => _deleteOrder(o['id'] as int),
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: status,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'Pending', child: Text('En attente')),
          DropdownMenuItem(value: 'Confirmed', child: Text('Confirmée')),
          DropdownMenuItem(value: 'Cancelled', child: Text('Annulée')),
          DropdownMenuItem(value: 'Shipped', child: Text('Expédiée')),
          DropdownMenuItem(value: 'Delivered', child: Text('Livrée')),
        ],
        onChanged: (value) {
          if (value == null) return;
          _setOrderStatus(order['id'] as int, value);
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatItems(String? jsonItems) {
    if (jsonItems == null || jsonItems.isEmpty) return '-';
    try {
      final raw = jsonDecode(jsonItems);
      if (raw is! List) return jsonItems;
      return raw
          .whereType<Map>()
          .map((e) => '${e['name'] ?? 'Produit'} x${e['quantity'] ?? 1}')
          .toList()
          .join(', ');
    } catch (_) {
      return jsonItems;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  Widget _containerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: child,
    );
  }

  Widget _metricCard({required String title, required String value, bool dark = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: dark ? AppColors.burgundy : Colors.white,
          border: Border.all(color: dark ? Colors.transparent : AppColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: dark ? Colors.white70 : AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: dark ? Colors.white : AppColors.burgundy,
                fontSize: 42,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFEDE6C5), borderRadius: BorderRadius.circular(50)),
      child: Text(label, style: const TextStyle(color: AppColors.textDark)),
    );
  }
}
