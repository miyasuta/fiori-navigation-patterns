using NavigationTargetService as service from '../../srv/service';

// Labels for filter bar fields: indicate which Group B feature populates each field
annotate service.NavTargets with {
    orderId          @Common.Label: 'Order ID';
    supplierId       @Common.Label: 'Supplier ID';
    region           @Common.Label: 'Region';
    vendor           @Common.Label: 'vendor (B-2: SemanticObjectMapping)';
    supplierCategory @Common.Label: 'supplierCategory (B-3: IBN Mapping)';
    internalNote     @Common.Label: 'internalNote (B-4: ExcludeFromNavigationContext)';
};

annotate service.NavTargets with @(
    // SelectionFields: these fields appear in the filter bar and are auto-populated
    // when inbound navigation context matches the field names
    UI.SelectionFields: [
        orderId,
        supplierId,
        region,
        vendor,
        supplierCategory,
        internalNote,
    ],
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            { $Type: 'UI.DataField', Label: 'Title',             Value: title            },
            { $Type: 'UI.DataField', Label: 'Order ID',          Value: orderId          },
            { $Type: 'UI.DataField', Label: 'Supplier ID',       Value: supplierId       },
            { $Type: 'UI.DataField', Label: 'Region',            Value: region           },
            { $Type: 'UI.DataField', Label: 'Vendor',            Value: vendor           },
            { $Type: 'UI.DataField', Label: 'Supplier Category', Value: supplierCategory },
            { $Type: 'UI.DataField', Label: 'Internal Note',     Value: internalNote     },
        ],
    },
    UI.Facets : [{
        $Type  : 'UI.ReferenceFacet',
        ID     : 'GeneratedFacet1',
        Label  : 'General Information',
        Target : '@UI.FieldGroup#GeneratedGroup',
    }],
    UI.LineItem : [
        { $Type: 'UI.DataField', Label: 'Title',             Value: title            },
        { $Type: 'UI.DataField', Label: 'Order ID',          Value: orderId          },
        { $Type: 'UI.DataField', Label: 'Supplier ID',       Value: supplierId       },
        { $Type: 'UI.DataField', Label: 'Region',            Value: region           },
        { $Type: 'UI.DataField', Label: 'Vendor',            Value: vendor           },
        { $Type: 'UI.DataField', Label: 'Supplier Category', Value: supplierCategory },
        { $Type: 'UI.DataField', Label: 'Internal Note',     Value: internalNote     },
    ],
);
