import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/saved_analysis.dart';
import '../models/search_result.dart';
import '../providers/saved_analysis_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/search_result_card.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
    // Load data when page opens
    final provider = context.read<SavedAnalysisProvider>();
    Future.microtask(() => provider.loadAnalyses());
  }

  // === EXPORT HISTORY ===
  Future<void> _exportHistory() async {
    final provider = context.read<SavedAnalysisProvider>();

    if (provider.analyses.isEmpty) {
      _showSnackBar('Tidak ada data untuk diekspor', isError: true);
      return;
    }

    try {
      // Generate JSON
      final jsonString = provider.exportToJson();

      // Simpan ke file temporary
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'klarip_backup_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share file via system share dialog
      final xFile = XFile(file.path, mimeType: 'application/json');
      final result = await Share.shareXFiles(
        [xFile],
        subject: 'Backup Klarip - ${provider.analyses.length} koleksi',
        text:
            'Backup data koleksi Klarip (${provider.analyses.length} item)',
      );

      if (result.status == ShareResultStatus.success) {
        _showSnackBar('${provider.analyses.length} koleksi berhasil diekspor');
      }
    } catch (e) {
      _showSnackBar('Gagal mengekspor: $e', isError: true);
    }
  }

  // === IMPORT HISTORY ===
  Future<void> _importHistory() async {
    try {
      // Show confirmation dialog first
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Row(
            children: [
              Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text('Import Koleksi', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Pilih file backup (.json) dari Klarip untuk mengimpor koleksi. Data duplikat akan dilewati secara otomatis.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Pilih File'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primarySeedColor,
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        _showSnackBar('Gagal membaca file', isError: true);
        return;
      }

      // Read file content
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Row(
            children: [
              CircularProgressIndicator(color: AppTheme.primarySeedColor),
              SizedBox(width: 24),
              Text('Mengimpor data...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      // Import
      final provider = context.read<SavedAnalysisProvider>();
      final importedCount = await provider.importFromJson(jsonString);

      // Dismiss loading
      if (mounted) Navigator.pop(context);

      // Show result
      if (importedCount > 0) {
        _showSnackBar('$importedCount koleksi berhasil diimpor');
      } else {
        _showSnackBar(
          'Tidak ada data baru untuk diimpor (semua sudah ada)',
          isError: false,
        );
      }
    } on FormatException catch (e) {
      // Dismiss loading if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      // Dismiss loading if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnackBar('Gagal mengimpor: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : AppTheme.primarySeedColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SavedAnalysisProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Export/Import actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koleksi Fakta',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Arsip analisis hoaks dan catatan pribadi Anda.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Export / Import Menu
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      color: AppTheme.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      offset: const Offset(0, 48),
                      onSelected: (value) {
                        if (value == 'export') {
                          _exportHistory();
                        } else if (value == 'import') {
                          _importHistory();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'export',
                          enabled: provider.analyses.isNotEmpty,
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                color: provider.analyses.isNotEmpty
                                    ? AppTheme.primarySeedColor
                                    : Colors.white24,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ekspor Koleksi',
                                    style: TextStyle(
                                      color: provider.analyses.isNotEmpty
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    provider.analyses.isNotEmpty
                                        ? '${provider.analyses.length} item'
                                        : 'Tidak ada data',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(
                          value: 'import',
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_download_outlined,
                                color: Colors.cyanAccent,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Impor Koleksi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Dari file backup (.json)',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.analyses.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildList(provider.analyses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.white.withValues(alpha: 0.24),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada koleksi',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Simpan hasil analisis pencarian di sini.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 24),
          // Import button when empty
          OutlinedButton.icon(
            onPressed: _importHistory,
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Impor dari Backup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<SavedAnalysis> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _SavedItemCard(item: item);
      },
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final SavedAnalysis item;

  const _SavedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Verdict Badge & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getVerdictColor(
                        item.verdict,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getVerdictColor(
                          item.verdict,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _formatVerdict(item.verdict),
                      style: TextStyle(
                        color: _getVerdictColor(item.verdict),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      color: item.isFavorite ? Colors.amber : Colors.white38,
                    ),
                    onPressed: () {
                      context.read<SavedAnalysisProvider>().toggleFavorite(
                        item.id!,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title aka Claim
              Text(
                _cleanText(item.claim),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // User Note Preview
              if (item.userNote.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.userNote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(item: item),
    );
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return const Color(0xFF10B981);
      case 'TIDAK_DIDUKUNG_DATA':
        return const Color(0xFFEF4444);
      case 'MEMERLUKAN_VERIFIKASI':
        return const Color(0xFFF59E0B);
      case 'Hasil Pencarian':
        return Colors.cyanAccent;
      default:
        return Colors.blue;
    }
  }

  String _formatVerdict(String verdict) {
    if (verdict == 'Hasil Pencarian') return 'Pencarian Web';
    return verdict.replaceAll('_', ' ');
  }
}

class _DetailSheet extends StatefulWidget {
  final SavedAnalysis item;

  const _DetailSheet({required this.item});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.userNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // Share logic could be added here
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Claim Header
                Text(
                  'Klaim:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanText(widget.item.claim),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Analysis
                _buildAnalysisSection(theme),
                const SizedBox(height: 24),

                // Notes Section (Integrated CRUD Update)
                _buildNoteSection(theme),

                // Sources Link button removed per user request
                SizedBox(
                  height: isKeyboardVisible ? 300 : 40,
                ), // Keyboard spacer
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(ThemeData theme) {
    final isSearchResult = widget.item.verdict == 'Hasil Pencarian';
    final accentColor = isSearchResult ? Colors.cyanAccent : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSearchResult ? Icons.search : Icons.auto_awesome,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSearchResult ? 'Ringkasan Web' : 'Analisis AI',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.item.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          if (widget.item.analysis.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 32),
            _buildStructuredContent(theme, widget.item.analysis),
          ],
        ],
      ),
    );
  }

  Widget _buildStructuredContent(ThemeData theme, String analysisContent) {
    try {
      // Try to parse structured JSON
      final data = jsonDecode(analysisContent);
      if (data is Map &&
          data.containsKey('ai_analysis') &&
          data.containsKey('search_results')) {
        final aiText = data['ai_analysis'] as String;
        final rawResults = data['search_results'] as List;
        final results = rawResults
            .map((r) => SearchResult.fromJson(r as Map<String, dynamic>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aiText.isNotEmpty) ...[
              Text(
                aiText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Section header for search results
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primarySeedColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sumber Pencarian (${results.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (results.isNotEmpty)
              ...results.map(
                (res) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultCard(
                    result: res,
                    showSaveButton: false, // Already saved
                    onOpen: (url) async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    onCopy: (url) {
                      Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link disalin')),
                        );
                      }
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white30, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tidak ada sumber pencarian tersimpan untuk analisis ini.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }
    } catch (e) {
      debugPrint('Failed to parse structured content: $e');
    }

    // Default simple text display
    return Text(
      analysisContent,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white54,
        height: 1.5,
      ),
    );
  }

  Widget _buildNoteSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catatan Pribadi',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            if (!_isEditing)
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          Column(
            children: [
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tulis tanggapan atau catatan Anda...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _noteController.text = widget.item.userNote; // Reset
                      });
                    },
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<SavedAnalysisProvider>().updateNote(
                        widget.item.id!,
                        _noteController.text,
                      );
                      setState(() => _isEditing = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Catatan diperbarui')),
                        );
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              widget.item.userNote.isEmpty
                  ? 'Belum ada catatan'
                  : widget.item.userNote,
              style: TextStyle(
                color: widget.item.userNote.isEmpty
                    ? Colors.white30
                    : Colors.white70,
                fontStyle: widget.item.userNote.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Hapus Koleksi?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Analisis ini akan dihapus permanen dari penyimpanan lokal Anda.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<SavedAnalysisProvider>().deleteAnalysis(
                widget.item.id!,
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail sheet
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Item dihapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Helper untuk membersihkan teks jika berisi JSON (fallback data error)
String _cleanText(String text) {
  text = text.trim();
  if (text.startsWith('{') && text.endsWith('}')) {
    try {
      final data = jsonDecode(text);
      if (data is Map && data.containsKey('ai_analysis')) {
        // Ambil kalimat pertama dari analisis sebagai fallback title
        final analysis = data['ai_analysis'] as String;
        final summary = analysis.split('.').first;
        return summary.length > 100
            ? '${summary.substring(0, 100)}...'
            : summary;
      }
    } catch (_) {}
  }
  return text;
}
