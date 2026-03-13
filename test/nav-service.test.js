'use strict'

const cds = require('@sap/cds')
const { describe, it } = require('node:test')
const assert = require('node:assert/strict')

describe('NavigationSourceService', () => {
  const { GET } = cds.test(__dirname + '/..')

  it('listOrdersShouldReturnAllFields', async () => {
    const { data } = await GET('/odata/v4/navigation-source/Orders')
    assert.ok(data.value.length > 0, 'Orders should have sample data')
    const order = data.value[0]
    assert.ok('orderId' in order, 'orderId field required')
    assert.ok('description' in order, 'description field required')
    assert.ok('amount' in order, 'amount field required')
    assert.ok('status' in order, 'status field required')
    assert.ok('region' in order, 'region field required')
    assert.ok('supplierId' in order, 'supplierId field required')
    assert.ok('isNavEnabled' in order, 'isNavEnabled field required')
    assert.ok('externalUrl' in order, 'externalUrl field required')
  })

  it('listOrdersShouldExpandSupplier', async () => {
    const { data } = await GET('/odata/v4/navigation-source/Orders?$expand=_Supplier')
    assert.ok(data.value.length > 0)
    const order = data.value.find(o => o._Supplier)
    assert.ok(order, 'At least one order should have a Supplier')
    assert.ok('supplierName' in order._Supplier, 'supplierName required in Supplier')
    assert.ok('category' in order._Supplier, 'category required in Supplier')
  })

  it('listSuppliersShouldReturnAllFields', async () => {
    const { data } = await GET('/odata/v4/navigation-source/Suppliers')
    assert.ok(data.value.length > 0, 'Suppliers should have sample data')
    const supplier = data.value[0]
    assert.ok('supplierId' in supplier, 'supplierId field required')
    assert.ok('supplierName' in supplier, 'supplierName field required')
    assert.ok('region' in supplier, 'region field required')
    assert.ok('category' in supplier, 'category field required')
  })

  it('filterOrdersByIsNavEnabledShouldReturnEnabledOnly', async () => {
    const { data } = await GET('/odata/v4/navigation-source/Orders?$filter=isNavEnabled eq true')
    assert.ok(data.value.length > 0)
    data.value.forEach(o => assert.strictEqual(o.isNavEnabled, true))
  })
})

describe('NavigationTargetService', () => {
  const { GET } = cds.test(__dirname + '/..')

  it('listNavTargetsShouldReturnAllFields', async () => {
    const { data } = await GET('/odata/v4/navigation-target/NavTargets')
    assert.ok(data.value.length > 0, 'NavTargets should have sample data')
    const target = data.value[0]
    assert.ok('title' in target, 'title field required')
    assert.ok('orderId' in target, 'orderId field required')
    assert.ok('supplierId' in target, 'supplierId field required')
    assert.ok('region' in target, 'region field required')
    assert.ok('vendor' in target, 'vendor field required')
    assert.ok('supplierCategory' in target, 'supplierCategory field required')
  })
})

describe('Group B Annotation Structure', () => {
  const { GET } = cds.test(__dirname + '/..')

  // B-1 + B-3: SemanticObjectMapping must appear in $metadata for NavigationSourceService
  it('metadataShouldContainSemanticObjectMappingForSupplierId', async () => {
    const { data } = await GET('/odata/v4/navigation-source/$metadata')
    assert.ok(
      data.includes('SemanticObjectMapping'),
      'SemanticObjectMapping annotation must be present in $metadata'
    )
  })

  // B-4: Orders with isNavEnabled=false must exist (NavigationAvailable data prerequisite)
  it('ordersWithNavDisabledShouldExist', async () => {
    const { data } = await GET('/odata/v4/navigation-source/Orders?$filter=isNavEnabled eq false')
    assert.ok(data.value.length > 0, 'At least one order with isNavEnabled=false is required for B-4')
  })
})
