// ════════════════════════════════════════════════════════════
// PartnerRepository - With Optimistic Updates
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/repositories/base/optimistic_repository.dart';
import 'package:gsloution_mobile/common/api_factory/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';

class PartnerRepository extends OptimisticRepository<PartnerModel> {
  PartnerRepository._();

  static final PartnerRepository instance = PartnerRepository._();

  final StorageService _storage = StorageService.instance;

  // ════════════════════════════════════════════════════════════
  // Get Partners (Cache-first strategy)
  // ════════════════════════════════════════════════════════════

  Future<List<PartnerModel>> getPartners({
    bool forceRefresh = false,
    int? limit,
    int? offset,
  }) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cached = await _storage.getPartners(
          limit: limit,
          offset: offset,
        );

        if (cached.isNotEmpty) {
          if (kDebugMode) {
            print('✅ PartnerRepository: Loaded ${cached.length} partners from cache');
          }
          return cached;
        }
      }

      // Fetch from server
      final client = ApiClientFactory.instance.getClient();
      final partners = await client.searchRead(
        model: 'res.partner',
        domain: [['customer_rank', '>', 0]],
        fields: ['id', 'name', 'email', 'phone', 'mobile', 'street', 'city'],
        limit: limit ?? 1000,
        offset: offset,
      );

      // Convert to PartnerModel
      final partnerModels = partners
          .map((p) => PartnerModel.fromJson(p))
          .toList();

      // Save to cache
      if (offset == null || offset == 0) {
        await _storage.setPartners(partnerModels);
        await PrefUtils.setPartners(partnerModels.obs);
      }

      if (kDebugMode) {
        print('✅ PartnerRepository: Fetched ${partnerModels.length} partners from server');
      }

      return partnerModels;

    } catch (e) {
      if (kDebugMode) {
        print('❌ PartnerRepository: Error getting partners: $e');
      }

      // Fallback to cache on error
      return await _storage.getPartners(limit: limit, offset: offset);
    }
  }

  // ════════════════════════════════════════════════════════════
  // Create Partner (Optimistic)
  // ════════════════════════════════════════════════════════════

  Future<PartnerModel> createPartner(PartnerModel partner) async {
    // Create snapshot for rollback
    final allPartners = await _storage.getPartners();
    createSnapshot(allPartners);

    // Temporary ID for optimistic update
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticPartner = PartnerModel(
      id: tempId,
      name: partner.name,
      email: partner.email,
      phone: partner.phone,
      mobile: partner.mobile,
    );

    PartnerModel? createdPartner;

    await optimisticUpdate(
      localUpdate: () {
        // Add partner locally immediately
        allPartners.insert(0, optimisticPartner);
        _storage.setPartners(allPartners);
        PrefUtils.setPartners(allPartners.obs);

        if (kDebugMode) {
          print('⚡ PartnerRepository: Optimistically added partner');
        }
      },

      serverUpdate: () async {
        // Send to server
        final client = ApiClientFactory.instance.getClient();
        final result = await client.create(
          model: 'res.partner',
          values: partner.toJson(),
        );

        // Update with real ID
        final realId = result['id'] as int;
        createdPartner = PartnerModel(
          id: realId,
          name: partner.name,
          email: partner.email,
          phone: partner.phone,
          mobile: partner.mobile,
        );

        // Replace temp partner with real one
        final index = allPartners.indexWhere((p) => p.id == tempId);
        if (index != -1) {
          allPartners[index] = createdPartner!;
          await _storage.setPartners(allPartners);
          await PrefUtils.setPartners(allPartners.obs);
        }

        if (kDebugMode) {
          print('✅ PartnerRepository: Partner created on server with ID: $realId');
        }
      },

      rollback: () {
        // Rollback to snapshot
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _storage.setPartners(snapshot);
          PrefUtils.setPartners(snapshot.obs);

          if (kDebugMode) {
            print('↩️ PartnerRepository: Rolled back partner creation');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        if (kDebugMode) {
          print('❌ PartnerRepository: Error creating partner: $error');
        }
      },
    );

    return createdPartner ?? optimisticPartner;
  }

  // ════════════════════════════════════════════════════════════
  // Update Partner (Optimistic)
  // ════════════════════════════════════════════════════════════

  Future<void> updatePartner(int id, Map<String, dynamic> values) async {
    // Create snapshot for rollback
    final allPartners = await _storage.getPartners();
    createSnapshot(allPartners);

    // Find partner
    final index = allPartners.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Partner #$id not found');
    }

    final oldPartner = allPartners[index];

    await optimisticUpdate(
      localUpdate: () {
        // Update partner locally immediately
        final updatedPartner = PartnerModel(
          id: oldPartner.id,
          name: values['name'] ?? oldPartner.name,
          email: values['email'] ?? oldPartner.email,
          phone: values['phone'] ?? oldPartner.phone,
          mobile: values['mobile'] ?? oldPartner.mobile,
        );

        allPartners[index] = updatedPartner;
        _storage.setPartners(allPartners);
        _storage.updatePartner(updatedPartner);
        PrefUtils.setPartners(allPartners.obs);
        PrefUtils.updatePartner(updatedPartner);

        if (kDebugMode) {
          print('⚡ PartnerRepository: Optimistically updated partner #$id');
        }
      },

      serverUpdate: () async {
        // Send to server
        final client = ApiClientFactory.instance.getClient();
        await client.write(
          model: 'res.partner',
          ids: [id],
          values: values,
        );

        if (kDebugMode) {
          print('✅ PartnerRepository: Partner #$id updated on server');
        }
      },

      rollback: () {
        // Rollback to snapshot
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _storage.setPartners(snapshot);
          PrefUtils.setPartners(snapshot.obs);

          if (kDebugMode) {
            print('↩️ PartnerRepository: Rolled back partner update');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        if (kDebugMode) {
          print('❌ PartnerRepository: Error updating partner: $error');
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Partners
  // ════════════════════════════════════════════════════════════

  Future<List<PartnerModel>> searchPartners(String query) async {
    try {
      final allPartners = await _storage.getPartners();

      if (query.isEmpty) {
        return allPartners;
      }

      // Search in cache first
      final results = allPartners.where((partner) {
        final name = partner.name?.toLowerCase() ?? '';
        final email = partner.email?.toLowerCase() ?? '';
        final phone = partner.phone?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
               email.contains(searchQuery) ||
               phone.contains(searchQuery);
      }).toList();

      if (kDebugMode) {
        print('🔍 PartnerRepository: Found ${results.length} partners matching "$query"');
      }

      return results;

    } catch (e) {
      if (kDebugMode) {
        print('❌ PartnerRepository: Error searching partners: $e');
      }
      return [];
    }
  }
}
