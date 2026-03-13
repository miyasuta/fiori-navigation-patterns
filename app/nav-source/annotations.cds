using NavigationSourceService as service from '../../srv/service';

// A-1: Semantic Link — orderId column becomes a clickable semantic link
annotate service.Orders with {
    orderId @Common.SemanticObject: 'NavTarget';
};

// B-1: SemanticObjectMapping — supplierId (source) is passed as vendor (target)
// B-3: SemanticObjectMapping — _Supplier/category (nav field) is passed as supplierCategory (target)
// B-2 (no-op): _Supplier/region is NOT mapped → region field in nav-target remains empty after navigation
annotate service.Orders with {
    supplierId @Common.SemanticObjectMapping: [
        { LocalProperty: supplierId,           SemanticObjectProperty: 'vendor'           },
        { LocalProperty: '_Supplier/category', SemanticObjectProperty: 'supplierCategory' },
    ];
};

annotate service.Orders with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            { $Type: 'UI.DataField', Label: 'Order ID',    Value: orderId      },
            { $Type: 'UI.DataField', Label: 'Description', Value: description  },
            { $Type: 'UI.DataField', Label: 'Amount',      Value: amount       },
            { $Type: 'UI.DataField', Label: 'Status',      Value: status       },
            { $Type: 'UI.DataField', Label: 'Region',      Value: region       },
            { $Type: 'UI.DataField', Label: 'Supplier ID', Value: supplierId   },
            { $Type: 'UI.DataField', Label: 'Nav Enabled', Value: isNavEnabled },
        ],
    },
    UI.Facets : [{
        $Type  : 'UI.ReferenceFacet',
        ID     : 'GeneratedFacet1',
        Label  : 'General Information',
        Target : '@UI.FieldGroup#GeneratedGroup',
    }],
    UI.LineItem : [
        // A-1: orderId is a Semantic Link (rendered as link via @Common.SemanticObject above)
        { $Type: 'UI.DataField', Label: 'Order ID (A-1: Semantic Link)', Value: orderId      },

        // A-4: Inline IBN — one button per row, appears inside the row
        // B-4: NavigationAvailable hides the button for rows where isNavEnabled=false (ORD002, ORD005)
        {
            $Type               : 'UI.DataFieldForIntentBasedNavigation',
            Label               : 'Open (A-4: Inline)',
            SemanticObject      : 'NavTarget',
            Action              : 'display',
            RequiresContext     : true,
            Inline              : true,
            NavigationAvailable : isNavEnabled,
        },

        // A-5: URL Link — cell shows the URL and opens it in a new tab
        {
            $Type              : 'UI.DataFieldWithUrl',
            Label              : 'External Link (A-5)',
            Value              : externalUrl,
            Url                : externalUrl,
            ![@HTML5.LinkTarget]: '_blank',
        },

        // ── Data columns ──────────────────────────────────────────────────
        { $Type: 'UI.DataField', Label: 'Description', Value: description  },
        { $Type: 'UI.DataField', Label: 'Amount',      Value: amount       },
        { $Type: 'UI.DataField', Label: 'Status',      Value: status       },
        { $Type: 'UI.DataField', Label: 'Region',      Value: region       },
        { $Type: 'UI.DataField', Label: 'Supplier ID', Value: supplierId   },
        { $Type: 'UI.DataField', Label: 'Nav Enabled', Value: isNavEnabled },

        // ── Toolbar buttons ───────────────────────────────────────────────
        // A-2: IBN button always enabled (no row selection needed)
        {
            $Type          : 'UI.DataFieldForIntentBasedNavigation',
            Label          : 'Navigate (A-2: No Context)',
            SemanticObject : 'NavTarget',
            Action         : 'display',
            RequiresContext: false,
        },

        // A-3: IBN button requires row selection (disabled until a row is selected)
        // B-4: NavigationAvailable hides the button for rows where isNavEnabled=false (ORD002, ORD005)
        {
            $Type               : 'UI.DataFieldForIntentBasedNavigation',
            Label               : 'Navigate (A-3: With Context)',
            SemanticObject      : 'NavTarget',
            Action              : 'display',
            RequiresContext     : true,
            NavigationAvailable : isNavEnabled,
        },
    ],
);
