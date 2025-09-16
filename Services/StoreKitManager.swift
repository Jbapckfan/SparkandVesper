import StoreKit
import Combine

// MARK: - Product Identifiers
enum ProductID: String, CaseIterable {
    case removeAds = "com.sparkandvesper.removeads"
    case hintPack = "com.sparkandvesper.hintpack"
    case premiumLevels = "com.sparkandvesper.premiumlevels"
    case proVersion = "com.sparkandvesper.pro"
    case sparks100 = "com.sparkandvesper.sparks100"
    case sparks600 = "com.sparkandvesper.sparks600"
    case sparks1500 = "com.sparkandvesper.sparks1500"

    var price: String {
        switch self {
        case .removeAds: return "$3.99"
        case .hintPack: return "$1.99"
        case .premiumLevels: return "$4.99"
        case .proVersion: return "$7.99"
        case .sparks100: return "$0.99"
        case .sparks600: return "$4.99"
        case .sparks1500: return "$9.99"
        }
    }
}

// MARK: - StoreKit Manager
@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: Set<ProductID> = []
    @Published private(set) var isProcessingPurchase = false
    @Published private(set) var sparksBalance: Int = 0

    private var transactionListener: Task<Void, Error>?
    private let userDefaults = UserDefaults.standard

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
            loadSparksBalance()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading
    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductID.allCases.map { $0.rawValue })
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase Flow
    func purchase(_ productID: ProductID) async throws {
        guard let product = products.first(where: { $0.id == productID.rawValue }) else {
            throw StoreKitError.productNotFound
        }

        isProcessingPurchase = true
        defer { isProcessingPurchase = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()

            // Handle consumables (sparks)
            if productID == .sparks100 {
                addSparks(100)
            } else if productID == .sparks600 {
                addSparks(600)
            } else if productID == .sparks1500 {
                addSparks(1500)
            }

            await transaction.finish()

        case .userCancelled:
            throw StoreKitError.userCancelled

        case .pending:
            throw StoreKitError.pending

        @unknown default:
            throw StoreKitError.unknown
        }
    }

    // MARK: - Transaction Handling
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<ProductID> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let productID = ProductID(rawValue: transaction.productID) {
                    purchased.insert(productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        purchasedProducts = purchased
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Sparks Currency
    private func loadSparksBalance() {
        sparksBalance = userDefaults.integer(forKey: "sparksBalance")
        if sparksBalance == 0 {
            // Give new players some starting sparks
            sparksBalance = 50
            saveSparksBalance()
        }
    }

    private func saveSparksBalance() {
        userDefaults.set(sparksBalance, forKey: "sparksBalance")
    }

    func addSparks(_ amount: Int) {
        sparksBalance += amount
        saveSparksBalance()
    }

    func spendSparks(_ amount: Int) -> Bool {
        guard sparksBalance >= amount else { return false }
        sparksBalance -= amount
        saveSparksBalance()
        return true
    }

    // MARK: - Helper Methods
    var hasRemovedAds: Bool {
        purchasedProducts.contains(.removeAds) || purchasedProducts.contains(.proVersion)
    }

    var hasPremiumLevels: Bool {
        purchasedProducts.contains(.premiumLevels) || purchasedProducts.contains(.proVersion)
    }

    var hasHintPack: Bool {
        purchasedProducts.contains(.hintPack) || purchasedProducts.contains(.proVersion)
    }
}

// MARK: - Errors
enum StoreKitError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case failedVerification
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .userCancelled:
            return "Purchase cancelled"
        case .pending:
            return "Purchase pending"
        case .failedVerification:
            return "Purchase verification failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}