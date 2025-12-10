enum LiveEventStatus { scheduled, live, ended }

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  completed,
  cancelled,
}

enum UserRole { customer, seller, admin }

enum PaymentMethod { creditCard, paypal, bankTransfer, cashOnDelivery }

enum ProductCategory {
  electronics,
  fashion,
  home,
  beauty,
  sports,
  books,
  toys,
  other,
}

enum NotificationType {
  orderUpdate,
  liveEventStarting,
  priceDrop,
  newArrival,
  promotion,
}
