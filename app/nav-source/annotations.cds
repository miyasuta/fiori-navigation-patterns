using NavigationSourceService as service from '../../srv/service';

// A-1: Semantic Link — orderId column becomes a clickable semantic link
// B-1: SemanticObjectMapping on orderId — when A-1 link is followed, supplierId is renamed to vendor
// NOTE: SemanticObjectMapping must be co-located with SemanticObject and applies to A-1 only.
//       For IBN buttons (A-3/A-4), parameter renaming via this annotation has no effect.
// NOTE: Common.SemanticObjectMapping does NOT support navigation property paths (LocalProperty cannot
//       reference navigation entity fields). Navigation entity properties can only be passed via
//       DataFieldForIntentBasedNavigation.Mapping (IBN button pattern — see B-3 on A-3/A-4 below).
annotate service.Orders with {
    orderId @Common.SemanticObject: 'NavTarget'
            @Common.SemanticObjectMapping: [
                { LocalProperty: supplierId, SemanticObjectProperty: 'vendor' },
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
        // B-3: Mapping passes _Supplier.category as supplierCategory (navigation entity property)
        //      DataFieldForIntentBasedNavigation.Mapping supports navigation property paths;
        //      Common.SemanticObjectMapping does NOT → this is the correct pattern for B-3.
        // B-4: NavigationAvailable hides the button for rows where isNavEnabled=false (ORD002, ORD005)
        {
            $Type               : 'UI.DataFieldForIntentBasedNavigation',
            Label               : 'Open (A-4: Inline)',
            SemanticObject      : 'NavTarget',
            Action              : 'display',
            RequiresContext     : true,
            Inline              : true,
            NavigationAvailable : isNavEnabled,
            Mapping             : [
                { LocalProperty: _Supplier.category, SemanticObjectProperty: 'supplierCategory' },
            ],
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
        { $Type: 'UI.DataField', Label: 'Supplier ID',      Value: supplierId           },
        { $Type: 'UI.DataField', Label: 'Supplier Region',   Value: _Supplier.region    },
        // B-3: category must be visible in the table for SemanticObjectMapping to pass it
        { $Type: 'UI.DataField', Label: 'Supplier Category', Value: _Supplier.category  },
        { $Type: 'UI.DataField', Label: 'Nav Enabled',      Value: isNavEnabled         },

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
        // B-3: Mapping passes _Supplier.category as supplierCategory (navigation entity property)
        // B-4: NavigationAvailable hides the button for rows where isNavEnabled=false (ORD002, ORD005)
        {
            $Type               : 'UI.DataFieldForIntentBasedNavigation',
            Label               : 'Navigate (A-3: With Context)',
            SemanticObject      : 'NavTarget',
            Action              : 'display',
            RequiresContext     : true,
            NavigationAvailable : isNavEnabled,
            Mapping             : [
                { LocalProperty: _Supplier.category, SemanticObjectProperty: 'supplierCategory' },
            ],
        },
    ],
);
