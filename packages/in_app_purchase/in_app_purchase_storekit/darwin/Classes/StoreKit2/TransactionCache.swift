import StoreKit

@available(iOS 15.0, *)
// make this injectable
class TransactionCache {
  private var cache: [Transaction]

  static var shared = TransactionCache()
  private init() {
    cache = []
  }

  func add(transaction: Transaction) {
    cache.append(transaction)
  }

  func remove(id: Int) -> Bool {
    if cache.contains(where: {transaction in transaction.id == id}) {
      cache.removeAll { transaction in
        transaction.id == id
      }
      return true;
    }
    return false;
  }

  func get(id: Int) -> Transaction? {
    let res = cache.first(where: { transaction in
      transaction.id == id
    })
    return res
  }
}
