@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View - Unmanaged Mobile System'
define root view entity ZI_MobInv_U_083 
  as select from zmb_inv_u_083
  // This association is needed for the Contact Card feature
  association [0..1] to ZI_SUPPLIER_083 as _Supplier on $projection.SupplierId = _Supplier.SupplierId
{
  key store_id as StoreId,
  key phone_id as PhoneId,
  brand as Brand,
  model as Model,
  @Semantics.amount.currencyCode: 'Currency'
  price as Price,
  currency as Currency,
  stock_count as StockCount,
  delivery_model as DeliveryModel,
  payment_method as PaymentMethod,
  payment_status as PaymentStatus,
  invoice_status as InvoiceStatus,

  // --- ADD THESE FIELDS HERE (CRITICAL) ---
  max_capacity as MaxCapacity,
  supplier_id as SupplierId,
  image_url as ImageUrl,
  // ----------------------------------------

  case payment_status 
    when 'PAID' then 3    
    when 'PENDING' then 1 
    else 0                
  end as PaymentCriticality,

  case 
    when stock_count > 10 then 3 
    when stock_count between 1 and 10 then 2 
    else 1 
  end as StockCriticality,

  created_by as CreatedBy,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  last_changed_at as LastChangedAt,
  local_last_changed_at as LocalLastChangedAt,
  
  _Supplier
}
