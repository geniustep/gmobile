import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/services/draft/draft_sale_service.dart';

mixin DraftSaleMixin<T extends StatefulWidget> on State<T> {
  final DraftSaleService _draftService = DraftSaleService.instance;
  String? _currentDraftId;

  Future<void> saveDraftAutomatically(Map<String, dynamic> draftData) async {
    try {
      if (_currentDraftId != null) {
        draftData['id'] = _currentDraftId;
      }
      _currentDraftId = await _draftService.saveDraft(draftData);
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  Future<Map<String, dynamic>?> loadActiveDraft() async {
    try {
      final draft = await _draftService.getActiveDraft();
      if (draft != null) {
        _currentDraftId = draft['id'];
      }
      return draft;
    } catch (e) {
      debugPrint('Error loading draft: $e');
      return null;
    }
  }

  Future<void> showDraftLoadDialog() async {
    final hasDraft = await _draftService.getActiveDraft();

    if (hasDraft != null && mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('مسودة محفوظة'),
          content: const Text('لديك مسودة محفوظة. هل تريد استكمالها؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('بداية جديدة'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('استكمال'),
            ),
          ],
        ),
      );

      if (result == true) {
        await loadAndApplyDraft(hasDraft);
      } else {
        await _draftService.clearActiveDraft();
        _currentDraftId = null;
      }
    }
  }

  Future<void> loadAndApplyDraft(Map<String, dynamic> draft);

  Future<void> clearDraft() async {
    if (_currentDraftId != null) {
      await _draftService.deleteDraft(_currentDraftId!);
      _currentDraftId = null;
    }
  }

  Future<void> openDraftsScreen() async {
    final result = await Get.toNamed('/draftSales');
    if (result != null && result is Map<String, dynamic>) {
      await loadAndApplyDraft(result);
    }
  }
}
