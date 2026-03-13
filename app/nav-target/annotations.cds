using NavigationTargetService as service from '../../srv/service';

annotate service.NavTargets with @(
    // SelectionFields: these fields appear in the filter bar and are auto-populated
    // when inbound navigation context matches the field names
    UI.SelectionFields: [
        orderId,
        supplierId,
        region,
        vendor,
        supplierCategory,
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
    ],
);
