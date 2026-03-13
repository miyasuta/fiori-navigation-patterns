namespace nav.showcase;

entity Suppliers {
  key supplierId   : String(10);
      supplierName : String(100);
      region       : String(10);
      category     : String(50);
}

entity Orders {
  key orderId      : String(10);
      description  : String(100);
      amount       : Decimal(10, 2);
      status       : String(20);
      region       : String(10);
      supplierId   : String(10);
      isNavEnabled : Boolean;
      externalUrl  : String(200);
      _Supplier    : Association to Suppliers on _Supplier.supplierId = supplierId;
}

entity NavTargets {
  key id               : UUID;
      title            : String(200);
      orderId          : String(10);
      supplierId       : String(10);
      region           : String(10);
      vendor           : String(10);
      supplierCategory : String(50);
}
