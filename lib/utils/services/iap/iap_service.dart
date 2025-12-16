import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../storage/storage_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final _storage = StorageService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  final Set<String> _productIds = {
    'coins_500',
    'coins_1200',
    'coins_2500',
    'coins_5500',
    'coins_12000',
    'coins_30000',
  };

  final Map<String, int> _coinAmounts = {
    'coins_500': 500,
    'coins_1200': 1200,
    'coins_2500': 2500,
    'coins_5500': 5500,
    'coins_12000': 12000,
    'coins_30000': 30000,
  };

  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
    } catch (e) {
      print('IAP check failed: $e');
      _isAvailable = false;
    }

    if (!_isAvailable) {
      print('IAP not available on this device or emulator');
      return;
    }

    try {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: (error) {
          print('Purchase stream error: $error');
        },
      );
    } catch (e) {
      print('Failed to subscribe to purchaseStream: $e');
      return;
    }

    try {
      await _loadProducts();
      await _restorePurchases();
    } catch (e) {
      print('Error loading products or restoring purchases: $e');
    }
  }


  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }

    if (response.productDetails.isEmpty) {
      print('No products found');
      return;
    }

    _products = response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      throw Exception('IAP not available');
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true,
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else if (purchase.status == PurchaseStatus.error) {
        _handleError(purchase.error!);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _deliverProduct(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final coins = _coinAmounts[productId] ?? 0;

    if (coins > 0) {
      final currentCoins = _storage.getInt('user_coins', 0);
      await _storage.setInt('user_coins', currentCoins + coins);

      print('Delivered $coins coins');
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  void _showPendingUI() {
    print('Purchase pending...');
  }

  void _handleError(IAPError error) {
    print('Purchase error: ${error.message}');
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(error) {
    print('Purchase stream error: $error');
  }

  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  String getProductPrice(String productId) {
    final product = getProductById(productId);
    return product?.price ?? '\$0.00';
  }

  void dispose() {
    _subscription?.cancel();
  }
}