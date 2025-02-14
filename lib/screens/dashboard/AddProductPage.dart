import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/firebase_service.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedCategory = '';
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];
  bool _isLoading = false;
  List<String> _categories = [];
  final FirebaseService _firebaseService = FirebaseService();

  // Nouvelles variables pour l'upload d'image
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Nouvelle méthode pour sélectionner une image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  // Nouvelle méthode pour uploader l'image
  Future<String?> _uploadImage() async {
  if (_imageFile == null) return null;

  try {
    final String cloudName = 'dgdhrhnar'; // Remplace par ton Cloudinary Cloud Name
    final String uploadPreset = 'image_product'; // Remplace par ton Upload Preset

    final Uri uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      final String imageUrl = data['secure_url'];
      print('Upload réussi: $imageUrl');
      return imageUrl;
    } else {
      throw Exception('Échec de l\'upload: ${data['error']['message']}');
    }
  } catch (e) {
    print('Erreur d\'upload vers Cloudinary: $e');
    _showErrorSnackBar('Échec de l\'upload, réessayez.');
    return null;
  }
}

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            icon: Icon(icon, color: Theme.of(context).primaryColor),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  // Modified _buildImagePreview pour inclure l'upload d'image
  Widget _buildImagePreview() {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Image',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select image',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Uploading image...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOptions() {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Available Sizes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((size) {
                final isSelected = _selectedSizes.contains(size);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSizes.add(size);
                        } else {
                          _selectedSizes.remove(size);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Available Colors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildColorChips(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildColorChips() {
    final colors = {
      'Black': Colors.black,
      'White': Colors.white,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
    };

    return colors.entries.map((entry) {
      final isSelected = _selectedColors.contains(entry.key);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: FilterChip(
          label: Text(
            entry.key,
            style: TextStyle(
              color: entry.key == 'White' ? Colors.black : null,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedColors.add(entry.key);
              } else {
                _selectedColors.remove(entry.key);
              }
            });
          },
          selectedColor: entry.value.withOpacity(0.2),
          checkmarkColor: entry.key == 'White' ? Colors.black : Colors.white,
          backgroundColor: Colors.white.withOpacity(0.3),
          avatar: CircleAvatar(
            backgroundColor: entry.value,
            radius: 10,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePreview(),
                        const SizedBox(height: 20),
                        _buildGlassContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Information',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Product Name',
                                  icon: Icons.shopping_bag,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Please enter a product name' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  controller: _descriptionController,
                                  label: 'Description',
                                  icon: Icons.description,
                                  maxLines: 3,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Please enter a description' : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        controller: _priceController,
                                        label: 'Price',
                                        icon: Icons.attach_money,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'Please enter a price';
                                          }
                                          if (double.tryParse(value!) == null) {
                                            return 'Please enter a valid number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        controller: _brandController,
                                        label: 'Brand',
                                        icon: Icons.branding_watermark,
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Please enter a brand' : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProductOptions(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Add Product',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // Modified _submitProduct pour inclure l'upload d'image
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      // Upload image first
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        _showErrorSnackBar('Failed to upload image');
        setState(() => _isLoading = false);
        return;
      }

      final newProduct = Product(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imagePath: imageUrl,
        category: _selectedCategory,
        brand: _brandController.text,
        sizes: _selectedSizes,
        colors: _selectedColors,
        rating: 0,
        deliveryTime: 0.0,
      );

      await _firebaseService.addProduct(newProduct);
      _showSuccessSnackBar('Product added successfully');
      _resetForm();
    } catch (e) {
      _showErrorSnackBar('Error adding product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _brandController.clear();
    _imageUrlController.clear();
    setState(() {
      _selectedCategory = '';
      _selectedSizes.clear();
      _selectedColors.clear();
      _selectedImage = null;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 6,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 6,
      ),
    );
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firebaseService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load categories: $e');
    }
  }

  Widget _buildCategorySelector() {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                dropdownColor: Colors.white.withOpacity(0.9),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required Widget child,
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPulseButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        child: child,
      ),
    );
  }
}
