import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cart_store.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/memorini_header.dart';

class CustomOrderPage extends StatefulWidget {
  const CustomOrderPage({super.key});

  @override
  State<CustomOrderPage> createState() => _CustomOrderPageState();
}

class _CustomOrderPageState extends State<CustomOrderPage> {
  final List<PlatformFile> _photoFiles = [];
  final List<PlatformFile> _cadreFiles = [];

  String _photoFormat = 'Polaroid';
  int _photoQty = 20;
  String _albumColor = 'Beige';
  String _albumSize = 'M';
  int _albumQty = 1;
  String _cadreColor = 'Bois';
  String _cadreDimension = '15 × 21 cm';
  int _cadreQty = 1;

  double get _photoUnitPrice {
    if (_photoFormat == 'Polaroid') return 1.50;
    if (_photoFormat == '13 × 21 cm') return 1.20;
    return 0.80;
  }

  double get _albumUnitPrice {
    if (_albumSize == 'S') return 25;
    if (_albumSize == 'L') return 95;
    return 55;
  }

  double get _cadreUnitPrice {
    if (_cadreDimension == '21 × 30 cm') return 28;
    if (_cadreDimension == '7 × 5 cm') return 18;
    return 22;
  }

  int get _photosNeededForCadres => _cadreQty;

  Future<bool> _requireLogin() async {
    final userId = await ApiService.getUserId();
    if (userId != null) return true;
    if (!mounted) return false;
    AppToast.show(
      context,
      message: 'Vous devez vous connecter avant d’ajouter au panier.',
      type: AppToastType.warning,
    );
    Navigator.pushNamed(context, '/login');
    return false;
  }

  Future<void> _pickPrintPhotos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: false,
    );
    if (result == null) return;
    if (result.files.length < 20) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Vous devez choisir au minimum 20 photos.',
        type: AppToastType.error,
      );
      return;
    }
    setState(() {
      _photoFiles
        ..clear()
        ..addAll(result.files);
      _photoQty = result.files.length;
    });
  }

  Future<void> _pickCadrePhotos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: false,
    );
    if (result == null) return;
    if (result.files.length != _photosNeededForCadres) {
      if (!mounted) return;
      AppToast.show(
        context,
        message:
            'Vous devez choisir exactement $_photosNeededForCadres photo(s) pour ce cadre.',
        type: AppToastType.error,
      );
      return;
    }
    setState(() {
      _cadreFiles
        ..clear()
        ..addAll(result.files);
    });
  }

  List<String> _fileNames(List<PlatformFile> files) =>
      files.map((file) => file.name).toList();

  Future<void> _addPhotosToCart() async {
    if (!await _requireLogin()) return;
    if (_photoFiles.length < 20) {
      AppToast.show(
        context,
        message: 'Vous devez choisir au minimum 20 photos.',
        type: AppToastType.error,
      );
      return;
    }
    CartStore.add(
      CartItem(
        id: 'photos-$_photoFormat-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Impression photos',
        type: 'photos',
        details: 'Format : $_photoFormat',
        qty: _photoQty,
        unitPrice: _photoUnitPrice,
        photos: _fileNames(_photoFiles),
      ),
    );
    _showAddedMessage();
  }

  Future<void> _addAlbumToCart() async {
    if (!await _requireLogin()) return;
    CartStore.add(
      CartItem(
        id: 'album-$_albumSize-$_albumColor',
        name: 'Album $_albumSize $_albumColor',
        type: 'album',
        details: 'Taille : $_albumSize | Couleur : $_albumColor',
        qty: _albumQty,
        unitPrice: _albumUnitPrice,
      ),
    );
    _showAddedMessage();
  }

  Future<void> _addCadreToCart() async {
    if (!await _requireLogin()) return;
    if (_cadreFiles.length != _photosNeededForCadres) {
      AppToast.show(
        context,
        message:
            'Vous devez choisir exactement $_photosNeededForCadres photo(s) pour ce cadre.',
        type: AppToastType.error,
      );
      return;
    }
    CartStore.add(
      CartItem(
        id: 'cadre-$_cadreDimension-$_cadreColor-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cadre personnalisé',
        type: 'cadre',
        details: 'Dimension : $_cadreDimension | Couleur : $_cadreColor',
        qty: _cadreQty,
        unitPrice: _cadreUnitPrice,
        photos: _fileNames(_cadreFiles),
      ),
    );
    _showAddedMessage();
  }

  void _showAddedMessage() {
    AppToast.show(
      context,
      message: 'Produit ajouté au panier.',
      type: AppToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? 'photos';
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(activeRoute: '/products'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 44),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                      ),
                      const SizedBox(height: 10),
                      if (type == 'album')
                        _albumPage()
                      else if (type == 'cadre')
                        _cadrePage()
                      else
                        _photosPage(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photosPage() {
    final total = _photoQty * _photoUnitPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          'Impression Photos',
          'Choisissez le format puis ajoutez au minimum 20 photos.',
        ),
        _card(
          children: [
            const Text('Format', style: _labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _choice(
                  'Polaroid',
                  '1.50 DT / photo',
                  _photoFormat == 'Polaroid',
                  () => setState(() => _photoFormat = 'Polaroid'),
                ),
                _choice(
                  '10 × 15 cm',
                  '0.80 DT / photo',
                  _photoFormat == '10 × 15 cm',
                  () => setState(() => _photoFormat = '10 × 15 cm'),
                ),
                _choice(
                  '13 × 21 cm',
                  '1.20 DT / photo',
                  _photoFormat == '13 × 21 cm',
                  () => setState(() => _photoFormat = '13 × 21 cm'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Photos', style: _labelStyle),
            const SizedBox(height: 8),
            _uploadBox(
              text: _photoFiles.isEmpty
                  ? 'Choose file / choisir vos photos'
                  : '${_photoFiles.length} photos sélectionnées',
              onTap: _pickPrintPhotos,
            ),
            const SizedBox(height: 8),
            const Text(
              'Minimum obligatoire : 20 photos.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
        _summary([
          _row('Quantité', '$_photoQty'),
          _row('Prix unitaire', '${_photoUnitPrice.toStringAsFixed(2)} DT'),
          _row('Total produit', '${total.toStringAsFixed(2)} DT'),
        ], _addPhotosToCart),
      ],
    );
  }

  Widget _albumPage() {
    final total = _albumQty * _albumUnitPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          'Album Photo',
          'Achat simple : choisissez taille et couleur. Aucun upload photo ici.',
        ),
        _card(
          children: [
            const Text('Couleur', style: _labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Beige', 'Vert', 'Rose', 'Blanc'].map((color) {
                return _simpleChoice(
                  color,
                  _albumColor == color,
                  () => setState(() => _albumColor = color),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text('Taille', style: _labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _choice(
                  'S',
                  '25 DT',
                  _albumSize == 'S',
                  () => setState(() => _albumSize = 'S'),
                ),
                _choice(
                  'M',
                  '55 DT',
                  _albumSize == 'M',
                  () => setState(() => _albumSize = 'M'),
                ),
                _choice(
                  'L',
                  '95 DT',
                  _albumSize == 'L',
                  () => setState(() => _albumSize = 'L'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _qtySelector(
              _albumQty,
              (value) => setState(() => _albumQty = value),
            ),
          ],
        ),
        _summary([
          _row('Produit', 'Album $_albumSize $_albumColor'),
          _row('Quantité', '$_albumQty'),
          _row('Prix unitaire', '${_albumUnitPrice.toStringAsFixed(2)} DT'),
          _row('Total produit', '${total.toStringAsFixed(2)} DT'),
        ], _addAlbumToCart),
      ],
    );
  }

  Widget _cadrePage() {
    final total = _cadreQty * _cadreUnitPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          'Cadre Personnalisé',
          'Choisissez le cadre puis sélectionnez seulement les photos qui vont dedans.',
        ),
        _card(
          children: [
            const Text('Couleur', style: _labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Bois', 'Noir', 'Blanc'].map((color) {
                return _simpleChoice(
                  color,
                  _cadreColor == color,
                  () => setState(() => _cadreColor = color),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text('Dimension', style: _labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _choice(
                  '7 × 5 cm',
                  '18 DT',
                  _cadreDimension == '7 × 5 cm',
                  () => setState(() => _cadreDimension = '7 × 5 cm'),
                ),
                _choice(
                  '15 × 21 cm',
                  '22 DT',
                  _cadreDimension == '15 × 21 cm',
                  () => setState(() => _cadreDimension = '15 × 21 cm'),
                ),
                _choice(
                  '21 × 30 cm',
                  '28 DT',
                  _cadreDimension == '21 × 30 cm',
                  () => setState(() => _cadreDimension = '21 × 30 cm'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _qtySelector(_cadreQty, (value) {
              setState(() {
                _cadreQty = value;
                _cadreFiles.clear();
              });
            }),
            const SizedBox(height: 22),
            const Text('Photos du/des cadre(s)', style: _labelStyle),
            const SizedBox(height: 8),
            _uploadBox(
              text: _cadreFiles.isEmpty
                  ? 'Choose file / choisir $_photosNeededForCadres photo(s)'
                  : '${_cadreFiles.length} photo(s) sélectionnée(s)',
              onTap: _pickCadrePhotos,
            ),
          ],
        ),
        _summary([
          _row('Cadre', '$_cadreDimension - $_cadreColor'),
          _row('Quantité', '$_cadreQty'),
          _row('Photos demandées', '$_photosNeededForCadres'),
          _row('Prix unitaire', '${_cadreUnitPrice.toStringAsFixed(2)} DT'),
          _row('Total produit', '${total.toStringAsFixed(2)} DT'),
        ], _addCadreToCart),
      ],
    );
  }

  Widget _title(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 42,
            color: AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _choice(
    String title,
    String subtitle,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.burgundy : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.burgundy : AppColors.softBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.burgundy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: selected ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleChoice(String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.burgundy : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.burgundy : AppColors.softBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.burgundy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _qtySelector(int qty, ValueChanged<int> onChanged) {
    return Row(
      children: [
        const Text('Quantité', style: _labelStyle),
        const SizedBox(width: 16),
        IconButton(
          onPressed: qty > 1 ? () => onChanged(qty - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$qty',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => onChanged(qty + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _uploadBox({required String text, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.upload_file),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        alignment: Alignment.centerLeft,
        foregroundColor: AppColors.burgundy,
        side: const BorderSide(color: AppColors.softBorder),
      ),
    );
  }

  Widget _summary(List<Widget> rows, VoidCallback onAdd) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          ...rows,
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter au panier'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              color: AppColors.burgundy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: AppColors.burgundy,
  fontWeight: FontWeight.bold,
);
