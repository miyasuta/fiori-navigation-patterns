# Fiori Elements Navigation Patterns Showcase

A CAP Node.js + SAP Fiori Elements (OData V4) project that demonstrates outbound navigation patterns from a List Report.

## Purpose

This project serves as a hands-on reference for developers learning how to implement cross-application navigation in SAP Fiori Elements apps. It covers two groups of patterns:

- **Group A** — How to trigger navigation (implemented)
- **Group B** — What context gets passed to the target app (planned)

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
  annotations.cds         — A-1 through A-5 annotations
  webapp/manifest.json    — A-6, crossNavigation.outbounds, FLP inbound

app/nav-target/
  annotations.cds         — SelectionFields for filter bar population
  webapp/manifest.json    — crossNavigation.inbounds (NavTarget-display, NavTarget-manage)

test/
  nav-service.test.js     — OData protocol-level tests
```
