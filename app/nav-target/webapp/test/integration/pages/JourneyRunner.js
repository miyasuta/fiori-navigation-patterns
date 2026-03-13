sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"navtarget/test/integration/pages/NavTargetsList",
	"navtarget/test/integration/pages/NavTargetsObjectPage"
], function (JourneyRunner, NavTargetsList, NavTargetsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('navtarget') + '/test/flpSandbox.html#navtarget-tile',
        pages: {
			onTheNavTargetsList: NavTargetsList,
			onTheNavTargetsObjectPage: NavTargetsObjectPage
        },
        async: true
    });

    return runner;
});

