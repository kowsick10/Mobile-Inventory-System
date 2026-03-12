@EndUserText.label: 'Mobile Inventory - Interactive View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_MobInv_U_083
  provider contract transactional_query
  as projection on ZI_MobInv_U_083
{
    @EndUserText.label: 'Store'
    key StoreId,

    @EndUserText.label: 'Device ID'
    key PhoneId,

    @Semantics.imageUrl: true
    @EndUserText.label: 'Device Preview'
    ImageUrl,

    @EndUserText.label: 'Manufacturer'
    Brand,

    @EndUserText.label: 'Model Name'
    Model,

    @Semantics.amount.currencyCode: 'Currency'
    @EndUserText.label: 'Retail Price'
    Price,

    @Semantics.currencyCode: true
    Currency,

    @EndUserText.label: 'Current Stock'
    StockCount,

    @EndUserText.label: 'Total Capacity'
    MaxCapacity,

    @EndUserText.label: 'Vendor'
    SupplierId,

    @EndUserText.label: 'Shipping Type'
    DeliveryModel,

    @EndUserText.label: 'Method'
    PaymentMethod,

    @EndUserText.label: 'Payment'
    PaymentStatus,

    @EndUserText.label: 'Invoice'
    InvoiceStatus,

    /* Support Fields for Visuals */
    @UI.hidden: true
    PaymentCriticality,
    @UI.hidden: true
    StockCriticality,

    _Supplier
}
