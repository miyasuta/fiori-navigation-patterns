using nav.showcase as db from '../db/schema';

@path: 'navigation-source'
service NavigationSourceService {
  entity Orders    as projection on db.Orders;
  entity Suppliers as projection on db.Suppliers;
}

@path: 'navigation-target'
service NavigationTargetService {
  entity NavTargets as projection on db.NavTargets;
}
