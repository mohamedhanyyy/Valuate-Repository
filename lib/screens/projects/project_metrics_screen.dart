import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../models/project_product.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/valuate_logo.dart';
import 'project_assumptions_screen.dart';
import 'project_detail_screen.dart';

class ProjectMetricsScreen extends StatefulWidget {
  final FeasibilityStudy study;

  const ProjectMetricsScreen({super.key, required this.study});

  @override
  State<ProjectMetricsScreen> createState() => _ProjectMetricsScreenState();
}

class _ProjectMetricsScreenState extends State<ProjectMetricsScreen> {
  late FeasibilityStudy _study;
  late List<ProjectProduct> _availableProducts;
  final List<ProjectProduct> _selectedProducts = [];
  String _selectedSectorFilter = 'all';

  String _canonicalizeSectorToDisplay(String s, bool isAr) {
    final lower = s.toLowerCase();
    if (s == 'all' || s == 'الكل' || lower == 'all') {
      return isAr ? 'الكل' : 'All';
    }
    if (lower.contains('res') || lower.contains('سكني')) {
      return isAr ? 'سكني' : 'Residential';
    }
    if (lower.contains('comm') || lower.contains('تجاري')) {
      return isAr ? 'تجاري' : 'Commercial';
    }
    if (lower.contains('hosp') || lower.contains('ضيافة')) {
      return isAr ? 'ضيافة' : 'Hospitality';
    }
    return s;
  }

  bool _sectorsMatch(String productSector, String filterSector) {
    final normFilter = filterSector.toLowerCase();
    if (normFilter == 'all' || filterSector == 'الكل' || normFilter == 'الكل') return true;
    final normProd = productSector.toLowerCase();
    if (normProd == normFilter) return true;
    if ((normProd.contains('res') || normProd.contains('سكني')) &&
        (normFilter.contains('res') || normFilter.contains('سكني'))) {
      return true;
    }
    if ((normProd.contains('comm') || normProd.contains('تجاري')) &&
        (normFilter.contains('comm') || normFilter.contains('تجاري'))) {
      return true;
    }
    if ((normProd.contains('hosp') || normProd.contains('ضيافة')) &&
        (normFilter.contains('hosp') || normFilter.contains('ضيافة'))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _study = widget.study;
    // Load available products for the study's sectors
    final sectors = _study.selectedSectors.isNotEmpty
        ? _study.selectedSectors
        : [_study.assetType];
    _availableProducts = ProjectProduct.defaultCatalogForSectors(sectors);

    // If study already has saved products, load them
    if (_study.products.isNotEmpty) {
      _selectedProducts.addAll(_study.products);
    }
  }

  double get _totalProductMixWeight {
    return _selectedProducts.fold(0.0, (acc, p) => acc + p.productMixPct);
  }

  List<ProjectProduct> get _filteredProducts {
    if (_selectedSectorFilter == 'all' || _selectedSectorFilter == 'الكل' || _selectedSectorFilter == 'All') {
      return _availableProducts;
    }
    return _availableProducts
        .where((p) => _sectorsMatch(p.sector, _selectedSectorFilter))
        .toList();
  }

  List<String> _getSectorFilters(bool isAr) {
    final sectors = _study.selectedSectors.isNotEmpty
        ? _study.selectedSectors
        : [_study.assetType];
    final localizedSectors = sectors.map((s) => _canonicalizeSectorToDisplay(s, isAr)).toSet().toList();
    return [isAr ? 'الكل' : 'All', ...localizedSectors];
  }

  void _openProductDialog(ProjectProduct templateProduct) async {
    // Check if product is already selected
    final existingIndex = _selectedProducts.indexWhere((p) => p.id == templateProduct.id || p.name == templateProduct.name);
    final initialProduct = existingIndex != -1 ? _selectedProducts[existingIndex] : templateProduct;

    final result = await showDialog<ProjectProduct>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _ProductDetailsDialog(
        product: initialProduct,
        study: _study,
      ),
    );

    if (result != null) {
      setState(() {
        if (existingIndex != -1) {
          _selectedProducts[existingIndex] = result;
        } else {
          _selectedProducts.add(result);
        }
      });
    }
  }

  void _removeProduct(ProjectProduct product) {
    setState(() {
      _selectedProducts.removeWhere((p) => p.id == product.id && p.name == product.name);
    });
  }

  void _saveMetrics() {
    final isAr = context.read<LocaleCubit>().state == 'ar';

    final updatedStudy = _study.copyWith(products: _selectedProducts);
    context.read<ProjectsCubit>().addOrUpdateStudy(updatedStudy);

    AppSnackBar.showSuccess(
      context,
      message: isAr
          ? 'تم حفظ مؤشرات ومواصفات المشروع بنجاح'
          : 'Project metrics & specifications saved successfully',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectAssumptionsScreen(study: updatedStudy),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ValuateLogo(height: 22, isDark: isDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _study.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(study: _study),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr ? 'تخطي' : 'Skip',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.lightTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.white70 : AppColors.lightTextMuted,
                  size: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Right Card in RTL (Start): Catalog Card
                  Expanded(
                    flex: 65,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      constraints: const BoxConstraints(minHeight: 540),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131B31) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E284A) : AppColors.lightBorder,
                        ),
                      ),
                      child: _buildCatalogContent(isDark, isAr, isMobile: false),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 2. Left Card in RTL (End): Selected Products Card
                  Expanded(
                    flex: 35,
                    child: _buildSelectedProductsPanel(isDark, isAr, isMobile: false),
                  ),
                ],
              ),
            );
          } else {
            // Mobile / Narrow layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B31) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E284A) : AppColors.lightBorder,
                      ),
                    ),
                    child: _buildCatalogContent(isDark, isAr, isMobile: true),
                  ),
                  const SizedBox(height: 18),
                  _buildSelectedProductsPanel(isDark, isAr, isMobile: true),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCatalogContent(bool isDark, bool isAr, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle (Matching Screenshot)
        Text(
          isAr ? 'مؤشرات ومواصفات المشروع' : 'Project Metrics & Specifications',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'التفاصيل والقياسات الرئيسية التي تحدد نطاق المشروع وهيكله واستخداماته للأراضي.'
              : 'Key details and metrics defining the project scope, structure, and land uses.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.lightTextMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),

        // Blue Info Banner with Lightbulb (Matching Screenshot)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C1835) : const Color(0xFFEBF3FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.7),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF38BDF8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'اختر منتجاتك واملأ تفاصيلها' : 'Select your products and fill in their details',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Product Type Label & Filter Pills (Aligned to the right in RTL)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'نوع المنتج' : 'Product Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: _getSectorFilters(isAr).map((sector) {
                  final isSel = _selectedSectorFilter == sector ||
                      ((_selectedSectorFilter == 'all' || _selectedSectorFilter == 'الكل' || _selectedSectorFilter == 'All') &&
                          (sector == 'الكل' || sector == 'All')) ||
                      _sectorsMatch(sector, _selectedSectorFilter);
                  return InkWell(
                    onTap: () => setState(() => _selectedSectorFilter = sector),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel
                            ? Colors.white
                            : (isDark ? const Color(0xFF0E1528) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSel
                              ? Colors.white
                              : (isDark ? const Color(0xFF222F55) : AppColors.lightBorder),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        sector,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? const Color(0xFF0F172A)
                              : (isDark ? Colors.white : AppColors.lightText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Products Grid / Wrap (Matching Screenshot)
        if (_filteredProducts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                isAr ? 'لا توجد منتجات مسجلة لهذا القطاع' : 'No products found for this sector',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              final cardWidth = isNarrow
                  ? (constraints.maxWidth - 14) / 2
                  : 180.0;
              const cardHeight = 160.0;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.start,
                children: _filteredProducts.map((product) {
                  final isAdded = _selectedProducts.any((p) => p.name == product.name);
                  final addedProduct = isAdded
                      ? _selectedProducts.firstWhere((p) => p.name == product.name)
                      : null;

                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: InkWell(
                      onTap: () => _openProductDialog(product),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0E1528) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAdded
                                ? const Color(0xFF2563EB)
                                : (isDark ? const Color(0xFF1E284A) : AppColors.lightBorder),
                            width: isAdded ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(flex: 3),
                                  // Valuate [V] Mark (Always LTR)
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 19,
                                            height: 19,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1D274A),
                                              borderRadius: BorderRadius.circular(4.5),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.25),
                                                width: 0.8,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'V',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'sans-serif',
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Valuate',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFFE2E8F0) : AppColors.lightText,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(flex: 2),
                                  // Product Name
                                  Text(
                                    product.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : AppColors.lightText,
                                      height: 1.25,
                                    ),
                                  ),
                                  const Spacer(flex: 3),
                                ],
                              ),
                            ),
                            if (isAdded && addedProduct != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${addedProduct.productMixPct > 0 ? addedProduct.productMixPct.toStringAsFixed(0) : 0}%',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSelectedProductsPanel(bool isDark, bool isAr, {bool isMobile = false}) {
    final totalWeight = _totalProductMixWeight;

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      constraints: BoxConstraints(minHeight: isMobile ? 0 : 540),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B31) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E284A) : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                isAr ? 'المنتجات المختارة' : 'Selected Products',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAr ? 'ملخص المنتجات المختارة' : 'Summary of selected products',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 18),

              // Selected Products List
              if (_selectedProducts.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildSelectedProductCard(_selectedProducts[index], isDark, isAr),
                ),
            ],
          ),

          // Bottom Bar: "وزن المنتجات %" on the right, [حفظ] on the left
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    totalWeight > 0
                        ? '${isAr ? 'وزن المنتجات %' : 'Product Weight %'}  (${totalWeight.toStringAsFixed(0)}%)'
                        : (isAr ? 'وزن المنتجات %' : 'Product Weight %'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _saveMetrics,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF253565) : AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF384A80) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isAr ? 'حفظ' : 'Save',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProductCard(ProjectProduct p, bool isDark, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171F38) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF263255) : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_canonicalizeSectorToDisplay(p.sector, isAr)} • ${p.productMixPct.toStringAsFixed(0)}% • ${p.bua.toStringAsFixed(0)} m²',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white60 : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: isDark ? Colors.white70 : AppColors.lightText,
            onPressed: () => _openProductDialog(p),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: const Color(0xFFF87171),
            onPressed: () => _removeProduct(p),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsDialog extends StatefulWidget {
  final ProjectProduct product;
  final FeasibilityStudy study;

  const _ProductDetailsDialog({
    required this.product,
    required this.study,
  });

  @override
  State<_ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<_ProductDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _productMixController;
  late TextEditingController _plotAreaPctController;
  late TextEditingController _plotAreaController;
  late TextEditingController _landAreaController;
  late TextEditingController _fpPctController;
  late TextEditingController _fpAreaController;
  late TextEditingController _heightController;
  late TextEditingController _avgAreaController;
  late TextEditingController _utilityCapRateController;
  late TextEditingController _buaController;
  late TextEditingController _priceRateController;
  late TextEditingController _rentalRateController;
  late TextEditingController _marketRefController;
  late String _propertyFinishing;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _productMixController = TextEditingController(
      text: p.productMixPct > 0 ? p.productMixPct.toStringAsFixed(0) : '20',
    );
    _plotAreaPctController = TextEditingController(
      text: p.plotAreaPct > 0 ? p.plotAreaPct.toStringAsFixed(0) : '30',
    );
    _plotAreaController = TextEditingController(
      text: p.plotArea > 0 ? p.plotArea.toStringAsFixed(0) : '350',
    );
    _landAreaController = TextEditingController(
      text: p.landArea > 0
          ? p.landArea.toStringAsFixed(0)
          : (widget.study.landArea * 0.3).toStringAsFixed(0),
    );
    _fpPctController = TextEditingController(
      text: p.footprintPct > 0 ? p.footprintPct.toStringAsFixed(0) : '60',
    );
    _fpAreaController = TextEditingController(
      text: p.footprintArea > 0
          ? p.footprintArea.toStringAsFixed(0)
          : (widget.study.landArea * 0.3 * 0.6).toStringAsFixed(0),
    );
    _heightController = TextEditingController(
      text: p.heightMeters > 0 ? p.heightMeters.toStringAsFixed(0) : '15',
    );
    _avgAreaController = TextEditingController(
      text: p.avgArea > 0 ? p.avgArea.toStringAsFixed(0) : '250',
    );
    _utilityCapRateController = TextEditingController(
      text: p.utilityCapRatePct > 0 ? p.utilityCapRatePct.toStringAsFixed(0) : '25',
    );
    _buaController = TextEditingController(
      text: p.bua > 0
          ? p.bua.toStringAsFixed(0)
          : (widget.study.bua * 0.25).toStringAsFixed(0),
    );
    _priceRateController = TextEditingController(
      text: p.priceRate > 0
          ? p.priceRate.toStringAsFixed(0)
          : widget.study.expectedRevenuePerSqm.toStringAsFixed(0),
    );
    _rentalRateController = TextEditingController(
      text: p.rentalRate > 0 ? p.rentalRate.toStringAsFixed(0) : '850',
    );
    _marketRefController = TextEditingController(
      text: p.marketReference ?? '',
    );
    _propertyFinishing = p.propertyFinishing.isNotEmpty ? p.propertyFinishing : 'Fully finished';
  }

  @override
  void dispose() {
    _productMixController.dispose();
    _plotAreaPctController.dispose();
    _plotAreaController.dispose();
    _landAreaController.dispose();
    _fpPctController.dispose();
    _fpAreaController.dispose();
    _heightController.dispose();
    _avgAreaController.dispose();
    _utilityCapRateController.dispose();
    _buaController.dispose();
    _priceRateController.dispose();
    _rentalRateController.dispose();
    _marketRefController.dispose();
    super.dispose();
  }

  void _onSave() {
    final updated = widget.product.copyWith(
      productMixPct: double.tryParse(_productMixController.text) ?? 0.0,
      plotAreaPct: double.tryParse(_plotAreaPctController.text) ?? 0.0,
      plotArea: double.tryParse(_plotAreaController.text) ?? 0.0,
      landArea: double.tryParse(_landAreaController.text) ?? 0.0,
      footprintPct: double.tryParse(_fpPctController.text) ?? 0.0,
      footprintArea: double.tryParse(_fpAreaController.text) ?? 0.0,
      heightMeters: double.tryParse(_heightController.text) ?? 0.0,
      avgArea: double.tryParse(_avgAreaController.text) ?? 0.0,
      utilityCapRatePct: double.tryParse(_utilityCapRateController.text) ?? 0.0,
      propertyFinishing: _propertyFinishing,
      bua: double.tryParse(_buaController.text) ?? 0.0,
      priceRate: double.tryParse(_priceRateController.text) ?? 0.0,
      rentalRate: double.tryParse(_rentalRateController.text) ?? 0.0,
      marketReference: _marketRefController.text.trim().isNotEmpty ? _marketRefController.text.trim() : null,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Center(
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 720),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B33) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF263255) : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ),

                  // Title: e.g. "تفاصيل بانكت"
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        isAr ? 'تفاصيل ${widget.product.name}' : '${widget.product.name} Details',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 20),

              // Form Scrollable
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Product-Mix % & Plot Area %
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'نسبة مزيج المنتجات (%)' : 'Product-Mix %',
                                hint: isAr ? 'أدخل الوزن' : 'Enter weight',
                                controller: _productMixController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'نسبة مساحة القطعة (%)' : 'Plot Area %',
                                hint: isAr ? 'أدخل نسبة المساحة' : 'Enter plot area %',
                                controller: _plotAreaPctController,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 2: مساحة القطعة & مساحة الأرض
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'مساحة القطعة (م²)' : 'Plot Area (m²)',
                                hint: isAr ? 'أدخل مساحة القطعة' : 'Enter plot area',
                                controller: _plotAreaController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'مساحة الأرض (م²)' : 'Land Area (m²)',
                                hint: isAr ? 'أدخل مساحة الأرض' : 'Enter land area',
                                controller: _landAreaController,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 3: %FP & FP
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'نسبة البصمة الإنشائية (%)' : 'Footprint %',
                                hint: isAr ? 'أدخل نسبة البصمة' : 'Enter % footprint',
                                controller: _fpPctController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'مساحة البصمة الإنشائية (م²)' : 'Footprint Area (m²)',
                                hint: isAr ? 'أدخل مساحة البصمة' : 'Enter footprint area',
                                controller: _fpAreaController,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 4: الارتفاع (م) & متوسط المساحة (م²)
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'الارتفاع (م)' : 'Height (m)',
                                hint: isAr ? 'أدخل الارتفاع' : 'Enter height',
                                controller: _heightController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'متوسط المساحة (م²)' : 'Avg Area (m²)',
                                hint: isAr ? 'أدخل متوسط المساحة' : 'Enter avg area',
                                controller: _avgAreaController,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 5: Utility Cap Rate % & نوع التشطيب
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'كفاءة المرافق (%)' : 'Utility Cap Rate %',
                                hint: '25',
                                controller: _utilityCapRateController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'نوع التشطيب' : 'Property Finishing',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppColors.lightTextMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0E1528) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF263255) : AppColors.lightBorder,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _propertyFinishing,
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF131B33) : Colors.white,
                                        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'Fully finished',
                                            child: Text(
                                              isAr ? 'تشطيب كامل' : 'Fully finished',
                                              style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Core & Shell',
                                            child: Text(
                                              isAr ? 'بدون تشطيب (عظم)' : 'Core & Shell',
                                              style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Semi finished',
                                            child: Text(
                                              isAr ? 'نصف تشطيب' : 'Semi finished',
                                              style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _propertyFinishing = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 6: BUA & Market Reference
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'مساحة البناء الإجمالية (م²)' : 'Gross Built-up Area (BUA)',
                                hint: isAr ? 'أدخل مساحة البناء' : 'Enter BUA',
                                controller: _buaController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'مرجع السوق' : 'Market Reference',
                                hint: isAr ? 'اختياري: مثال: كود السوق' : 'Optional benchmark',
                                controller: _marketRefController,
                                isDark: isDark,
                                isNumeric: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 7: Price Rate & Rental Rate
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'سعر المتر المربع' : 'Price / m²',
                                hint: isAr ? 'أدخل سعر البيع' : 'Price rate',
                                controller: _priceRateController,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: isAr ? 'سعر الإيجار / م²' : 'Rental Rate / m²',
                                hint: isAr ? 'أدخل سعر الإيجار' : 'Rental rate',
                                controller: _rentalRateController,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Save Button
              SizedBox(
                width: 140,
                child: PrimaryButton(
                  text: isAr ? 'حفظ' : 'Save',
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    bool isNumeric = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hint,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
        ),
      ],
    );
  }
}
