import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Local storage; overridden in `main()` with an initialised instance.
final storageProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('storageProvider must be overridden in main()'),
);

/// Backend gateway (currently mock).
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
