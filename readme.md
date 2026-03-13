# Fiori Elements Navigation Patterns Showcase

A CAP Node.js + SAP Fiori Elements (OData V4) project that demonstrates outbound navigation patterns from a List Report.

## Purpose

This project serves as a hands-on reference for developers learning how to implement cross-application navigation in SAP Fiori Elements apps. It covers two groups of patterns:

- **Group A** — How to trigger navigation (implemented)
- **Group B** — What context gets passed to the target app (implemented)

## Getting Started

```bash
npm install
cds watch
```

Open `http://localhost:4004/$launchpad` to access the FLP sandbox. Click the **Navigation Source** tile to open the List Report.

## App Structure

| App | Entity | Role |
|-----|--------|------|
| `app/nav-source` | Orders | Source app — demonstrates all navigation triggers |
| `app/nav-target` | NavTargets | Target app — shows received navigation context in filter bar |

---

## Group A — Navigation Triggers

All patterns are visible in the **nav-source List Report**.

![Navigation Source List Report](docs/images/source.png)

### A-1: Semantic Link

The `orderId` column renders as a clickable link. Clicking it opens a quick-actions popover listing all registered intents for the `NavTarget` semantic object. Since both `NavTarget-display` and `NavTarget-manage` are registered as inbounds, the popover shows two navigation options — demonstrating that a single semantic link can resolve to multiple targets.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
annotate service.Orders with {
    orderId @Common.SemanticObject: 'NavTarget';
};
```

**What to verify:** `orderId` cells appear as blue hyperlinks. Clicking one opens a popover with two options: "Navigation Target" (display) and "Navigation Target (Manage)" (manage).

---

### A-2: Intent-Based Navigation (IBN) Button (always enabled)

A toolbar button that is always active, even without selecting a row. Navigates to `NavTarget-display` with no entity context.

IBN (Intent-Based Navigation) is a decoupled navigation mechanism in SAP Fiori. Instead of hardcoding a target URL, the source app declares a semantic intent (`SemanticObject` + `Action`). The FLP resolves the intent at runtime and routes to the registered target app.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
{
    $Type          : 'UI.DataFieldForIntentBasedNavigation',
    Label          : 'Navigate (A-2: No Context)',
    SemanticObject : 'NavTarget',
    Action         : 'display',
    RequiresContext: false,
}
```

**What to verify:** The button is enabled before any row is selected.

---

### A-3: IBN Action (requires row selection)

A toolbar button that is disabled until one or more rows are selected. Passes the selected row's context to the target.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
{
    $Type          : 'UI.DataFieldForIntentBasedNavigation',
    Label          : 'Navigate (A-3: With Context)',
    SemanticObject : 'NavTarget',
    Action         : 'display',
    RequiresContext: true,
}
```

**What to verify:** The button is greyed out initially; activates after selecting a row.

---

### A-4: Inline IBN

A button rendered inside each row (not in the toolbar). Each button carries that row's context.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
{
    $Type          : 'UI.DataFieldForIntentBasedNavigation',
    Label          : 'Open (A-4: Inline)',
    SemanticObject : 'NavTarget',
    Action         : 'display',
    RequiresContext: true,
    Inline         : true,
}
```

**What to verify:** A button appears inside each row.

> **Constraint:** Inline IBN buttons have no column header regardless of table type (GridTable or ResponsiveTable). This is by design in Fiori Elements — `Label` controls the button text only, not the column header.

---

### A-5: URL Link

A table column whose cell value is rendered as a hyperlink to an external URL. Opens in a new browser tab.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
{
    $Type              : 'UI.DataFieldWithUrl',
    Label              : 'External Link (A-5)',
    Value              : externalUrl,
    Url                : externalUrl,
    ![@HTML5.LinkTarget]: '_blank',
}
```

**What to verify:** The `External Link (A-5)` column shows clickable URLs that open in a new tab.

---

### A-6: Replace Row-Click Navigation

By default, clicking a row navigates to the Object Page. This pattern replaces that behavior so the row click (chevron) navigates to an external app instead.

**Implementation** — `app/nav-source/webapp/manifest.json`:
```json
"sap.app": {
  "crossNavigation": {
    "outbounds": {
      "NavTargetDisplay": {
        "semanticObject": "NavTarget",
        "action": "display"
      }
    }
  }
},
"sap.ui5": {
  "routing": {
    "targets": {
      "OrdersList": {
        "options": {
          "settings": {
            "navigation": {
              "Orders": {
                "detail": {
                  "outbound": "NavTargetDisplay"
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**What to verify:** Clicking a row (or the chevron) navigates to the Navigation Target app instead of an Object Page.

> **Constraint:** Once `detail.outbound` is set, the Object Page is no longer reachable via row click. The route still exists in the manifest but is bypassed.

---

## Navigation Target App (nav-target)

The target app receives inbound navigation context and pre-populates the filter bar fields automatically when parameter names match `SelectionFields`.

**Inbound registration** — `app/nav-target/webapp/manifest.json`:
```json
"crossNavigation": {
  "inbounds": {
    "NavTarget-display": {
      "semanticObject": "NavTarget",
      "action": "display",
      "signature": {
        "parameters": {
          "orderId": { "required": false },
          "supplierId": { "required": false }
        },
        "additionalParameters": "allowed"
      }
    }
  }
}
```

**SelectionFields** — `app/nav-target/annotations.cds`:
```cds
UI.SelectionFields: [ orderId, supplierId, region, vendor, supplierCategory ]
```

**What to verify:** After navigating from nav-source, the filter bar in nav-target is pre-filled with the context values from the selected row.

---

---

## Group B — Navigation Context Control

All patterns control **what data is passed** to the target app during IBN navigation.

### B-1: SemanticObjectMapping (field rename)

`SemanticObjectMapping` renames a local field when it is passed as a navigation parameter. Here `supplierId` on the source is sent as `vendor` to the target.

**Applies to:** A-1 (Semantic Link) only. For IBN buttons (A-3/A-4) and row-click (A-6), parameter renaming via this annotation has no effect — those navigations pass fields under their original names.

**Key rule:** `@Common.SemanticObjectMapping` must be placed on the **same property** as `@Common.SemanticObject`. The FLP resolves the mapping only when following a semantic link tied to that semantic object.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
annotate service.Orders with {
    orderId @Common.SemanticObject: 'NavTarget'
            @Common.SemanticObjectMapping: [
                { LocalProperty: supplierId, SemanticObjectProperty: 'vendor' },
            ];
};
```

**What to verify (A-1 only):** Click the `orderId` semantic link. In nav-target, the `vendor` filter field is pre-filled with the order's `supplierId` value. The `supplierId` filter field is NOT pre-filled (parameter name was renamed).

> **One field, one target name:** A mapped field is sent *only* under the mapped name (`vendor`). It is **not** sent under its original name (`supplierId`) at the same time. If you need the value available under both names, you would need two separate fields — this is a structural constraint of `SemanticObjectMapping`.

---

### B-2: Association field without mapping — not passed

`Orders` has no direct `region` field. `Suppliers` has `region`, but it is only accessible via the `_Supplier` navigation property. Without a `SemanticObjectMapping` on `_Supplier`, `_Supplier/region` is excluded from the navigation context.

**Implementation:** No code change needed — the absence of mapping is the pattern itself.

**What to verify (A-1):** Click the `orderId` semantic link. In nav-target, the `region` filter field is **empty** — confirming that `_Supplier/region` is not passed by default.

---

### B-3: Association field with SemanticObjectMapping on the navigation property

Per SAP documentation, association fields are included in the navigation context **if a `SemanticObjectMapping` is defined on the navigation property itself** (not on a scalar property like `orderId`).

Here `_Supplier/category` is sent as `supplierCategory` by placing the mapping on `_Supplier`.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
annotate service.Orders with {
    _Supplier @Common.SemanticObjectMapping: [
        { LocalProperty: '_Supplier/category', SemanticObjectProperty: 'supplierCategory' },
    ];
};
```

**What to verify (A-1):** Click the `orderId` semantic link. In nav-target, the `supplierCategory` filter field is pre-filled with the supplier's `category` value. The `region` filter remains empty (no mapping for `_Supplier/region` — this is the B-2 contrast).

---

### B-4: NavigationAvailable (conditional button visibility)

`NavigationAvailable` controls whether an IBN button is shown for a given row. When the bound field is `false`, the button is hidden for that row.

In this project, `ORD002` and `ORD005` have `isNavEnabled = false` — their inline button (A-4) and context-aware toolbar button (A-3) are hidden.

**Implementation** — `app/nav-source/annotations.cds`:
```cds
// A-4 Inline
{
    $Type               : 'UI.DataFieldForIntentBasedNavigation',
    ...
    NavigationAvailable : isNavEnabled,
}

// A-3 Toolbar (requires selection)
{
    $Type               : 'UI.DataFieldForIntentBasedNavigation',
    ...
    NavigationAvailable : isNavEnabled,
}
```

**What to verify:** Rows for ORD002 and ORD005 show no inline navigation button. Selecting those rows keeps the A-3 toolbar button disabled.

> **Note:** `NavigationAvailable` does not apply to A-2 (`RequiresContext: false`) because that button carries no row context.

---

## Known Constraints

| Constraint | Detail |
|---|---|
| FLP sandbox only | Cross-app IBN requires an FLP context. Use `http://localhost:4004/$launchpad` — direct app URLs will not resolve intent-based navigation. |

---

## Project Structure

```
db/
  schema.cds              — Orders, Suppliers, NavTargets entities
  data/                   — CSV sample data (5 orders, 3 suppliers, 5 targets)

srv/
  service.cds             — NavigationSourceService, NavigationTargetService

app/nav-source/
  annotations.cds         — A-1 through A-5 annotations, B-1/B-3/B-4 context annotations
  webapp/manifest.json    — A-6, crossNavigation.outbounds, FLP inbound

app/nav-target/
  annotations.cds         — SelectionFields for filter bar population
  webapp/manifest.json    — crossNavigation.inbounds (NavTarget-display, NavTarget-manage)

test/
  nav-service.test.js     — OData protocol-level tests
```
