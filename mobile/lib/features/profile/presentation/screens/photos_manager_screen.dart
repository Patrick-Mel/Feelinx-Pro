import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/network/dio_client.dart';

class PhotosManagerScreen extends StatefulWidget {
  const PhotosManagerScreen({super.key});

  @override
  State<PhotosManagerScreen> createState() => _PhotosManagerScreenState();
}

class _PhotosManagerScreenState extends State<PhotosManagerScreen> {
  List<dynamic> _photos = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('profiles/me/');
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _photos = res.data['photos'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    if (_photos.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 9 photos autorisées.")),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final dio = DioClient().dio;
      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: image.name),
      });

      final res = await dio.post('profiles/me/photos/', data: formData);
      if (res.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo ajoutée avec succès !"), backgroundColor: FxColors.success),
        );
        _loadPhotos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi de la photo. Veuillez rééditer."), backgroundColor: FxColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    try {
      final dio = DioClient().dio;
      final res = await dio.delete('profiles/me/photos/$photoId/');
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo supprimée.")),
        );
        _loadPhotos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la suppression."), backgroundColor: FxColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = isDark ? FxColors.darkTextSecondary : FxColors.lightTextSecondary;
    final borderBg = isDark ? FxColors.darkBorder : FxColors.lightBorder;
    final cardBg = isDark ? FxColors.darkCard : FxColors.lightCard;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Mes photos", style: TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: FxColors.primaryCoral),
            onPressed: _isUploading ? null : _uploadPhoto,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FxColors.primaryCoral))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(FxSpacing.lg16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Gère tes photos de profil", style: FxTypography.titleLarge.copyWith(color: textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      "La première photo est ta photo principale. Ajoute jusqu'à 9 photos pour captiver tes matchs.",
                      style: FxTypography.bodyMedium.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 20),

                    if (_isUploading) ...[
                      const LinearProgressIndicator(color: FxColors.primaryCoral, backgroundColor: Colors.transparent),
                      const SizedBox(height: 12),
                    ],

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _photos.length + (_photos.length < 9 ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _photos.length) {
                            final photo = _photos[index];
                            final isPrimary = index == 0;
                            final resolvedUrl = DioClient.resolveImageUrl(photo['url']);

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isPrimary ? Border.all(color: FxColors.primaryCoral, width: 3) : Border.all(color: borderBg),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: CachedNetworkImage(
                                      imageUrl: resolvedUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Container(
                                        color: cardBg,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: FxColors.primaryCoral)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: cardBg,
                                        child: const Icon(Icons.broken_image_rounded, color: FxColors.error, size: 28),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isPrimary)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [FxColors.primaryCoral, FxColors.secondaryIndigo]),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(color: FxColors.primaryCoral.withValues(alpha: 0.4), blurRadius: 6),
                                        ],
                                      ),
                                      child: const Text(
                                        "Principale",
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _deletePhoto(photo['id']),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Add button slot
                            return InkWell(
                              onTap: _isUploading ? null : _uploadPhoto,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: FxColors.primaryCoral.withValues(alpha: 0.4), width: 1.5),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded, color: FxColors.primaryCoral, size: 32),
                                      SizedBox(height: 6),
                                      Text(
                                        "Ajouter",
                                        style: TextStyle(color: FxColors.primaryCoral, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
