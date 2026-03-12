@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Contact View'

define view entity ZI_SUPPLIER_083 as select from zsup_083
{
    @EndUserText.label: 'Supplier ID'
    key supplier_id as SupplierId,
    
    @Semantics.name.fullName: true
    @EndUserText.label: 'Supplier Name'
    supplier_name as SupplierName,
    
    @Semantics.eMail.address: true
    @EndUserText.label: 'Email'
    email as Email,
    
    @Semantics.telephone.type: [#WORK]
    @EndUserText.label: 'Phone'
    phone as Phone
}
