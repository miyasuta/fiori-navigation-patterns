sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"navsource/test/integration/pages/OrdersList",
	"navsource/test/integration/pages/OrdersObjectPage"
], function (JourneyRunner, OrdersList, OrdersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('navsource') + '/test/flpSandbox.html#navsource-tile',
        pages: {
			onTheOrdersList: OrdersList,
			onTheOrdersObjectPage: OrdersObjectPage
        },
        async: true
    });

    return runner;
});

