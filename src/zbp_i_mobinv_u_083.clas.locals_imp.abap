" ---------------------------------------------------------------------
" 1. LOCAL BUFFER CLASS
" ---------------------------------------------------------------------
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_insert TYPE TABLE OF zmb_inv_u_083,
                mt_update TYPE TABLE OF zmb_inv_u_083,
                mt_delete TYPE TABLE OF zmb_inv_u_083.
ENDCLASS.

" ---------------------------------------------------------------------
" 2. BEHAVIOR HANDLER CLASS
" ---------------------------------------------------------------------
CLASS lhc_MobileSystem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR MobileSystem RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MobileSystem RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE MobileSystem.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE MobileSystem.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE MobileSystem.
    METHODS read FOR READ
      IMPORTING keys FOR READ MobileSystem RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK MobileSystem.

    METHODS generateInvoice FOR MODIFY
      IMPORTING keys FOR ACTION MobileSystem~generateInvoice RESULT result.
    METHODS payWithGPay FOR MODIFY
      IMPORTING keys FOR ACTION MobileSystem~payWithGPay RESULT result.
    METHODS applyDiscount FOR MODIFY
      IMPORTING keys FOR ACTION MobileSystem~applyDiscount RESULT result.
ENDCLASS.

CLASS lhc_MobileSystem IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_mobinv_u_083 IN LOCAL MODE
      ENTITY MobileSystem
      FIELDS ( PaymentStatus InvoiceStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mobile).

    LOOP AT lt_mobile INTO DATA(ls_mobile).
      result = VALUE #( BASE result
        ( %tky = ls_mobile-%tky
          %action-payWithGPay = COND #( WHEN ls_mobile-PaymentStatus = 'PAID'
                                        THEN if_abap_behv=>fc-o-disabled
                                        ELSE if_abap_behv=>fc-o-enabled )
          %action-generateInvoice = COND #( WHEN ls_mobile-InvoiceStatus = 'GENERATED'
                                            THEN if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )
        ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD create.
    DATA: ls_insert TYPE zmb_inv_u_083.
    LOOP AT entities INTO DATA(ls_entity).
      TRY.
          ls_insert-phone_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      ls_insert-store_id       = ls_entity-StoreId.
      ls_insert-brand          = ls_entity-Brand.
      ls_insert-model          = ls_entity-Model.
      ls_insert-price          = ls_entity-Price.
      ls_insert-currency       = ls_entity-Currency.
      ls_insert-stock_count    = ls_entity-StockCount.
      ls_insert-max_capacity   = ls_entity-MaxCapacity.
      ls_insert-supplier_id    = ls_entity-SupplierId.
      ls_insert-image_url      = ls_entity-ImageUrl.
      ls_insert-delivery_model = ls_entity-DeliveryModel.
      ls_insert-payment_status = 'PENDING'.
      ls_insert-invoice_status = 'NONE'.
      GET TIME STAMP FIELD ls_insert-created_at.
      ls_insert-created_by     = sy-uname.

      APPEND ls_insert TO lcl_buffer=>mt_insert.

      INSERT VALUE #( %cid = ls_entity-%cid
                      StoreId = ls_entity-StoreId
                      PhoneId = ls_insert-phone_id ) INTO TABLE mapped-mobilesystem.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zmb_inv_u_083
        WHERE store_id = @ls_entity-StoreId AND phone_id = @ls_entity-PhoneId
        INTO @DATA(ls_update).

      IF sy-subrc = 0.
        IF ls_entity-%control-Brand = if_abap_behv=>mk-on. ls_update-brand = ls_entity-Brand. ENDIF.
        IF ls_entity-%control-Model = if_abap_behv=>mk-on. ls_update-model = ls_entity-Model. ENDIF.
        IF ls_entity-%control-Price = if_abap_behv=>mk-on. ls_update-price = ls_entity-Price. ENDIF.
        IF ls_entity-%control-StockCount = if_abap_behv=>mk-on. ls_update-stock_count = ls_entity-StockCount. ENDIF.
        IF ls_entity-%control-MaxCapacity = if_abap_behv=>mk-on. ls_update-max_capacity = ls_entity-MaxCapacity. ENDIF.
        IF ls_entity-%control-SupplierId = if_abap_behv=>mk-on. ls_update-supplier_id = ls_entity-SupplierId. ENDIF.
        IF ls_entity-%control-ImageUrl = if_abap_behv=>mk-on. ls_update-image_url = ls_entity-ImageUrl. ENDIF.
        IF ls_entity-%control-DeliveryModel = if_abap_behv=>mk-on. ls_update-delivery_model = ls_entity-DeliveryModel. ENDIF.

        GET TIME STAMP FIELD ls_update-last_changed_at.
        ls_update-last_changed_by = sy-uname.
        APPEND ls_update TO lcl_buffer=>mt_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( store_id = ls_key-StoreId phone_id = ls_key-PhoneId ) TO lcl_buffer=>mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      " First check database, then buffers
      SELECT SINGLE * FROM zmb_inv_u_083
        WHERE store_id = @ls_key-StoreId AND phone_id = @ls_key-PhoneId
        INTO @DATA(ls_db).

      " Check update buffer if database record was just modified
      READ TABLE lcl_buffer=>mt_update INTO ls_db WITH KEY store_id = ls_key-StoreId phone_id = ls_key-PhoneId.

      IF sy-subrc = 0 OR ls_db IS NOT INITIAL.
        INSERT CORRESPONDING #( ls_db MAPPING
            StoreId = store_id PhoneId = phone_id Brand = brand Model = model
            Price = price Currency = currency StockCount = stock_count
            MaxCapacity = max_capacity SupplierId = supplier_id ImageUrl = image_url
            DeliveryModel = delivery_model PaymentStatus = payment_status
            InvoiceStatus = invoice_status ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD generateInvoice.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zmb_inv_u_083 WHERE store_id = @ls_key-StoreId AND phone_id = @ls_key-PhoneId INTO @DATA(ls_db).
      IF sy-subrc = 0.
        ls_db-invoice_status = 'GENERATED'.
        APPEND ls_db TO lcl_buffer=>mt_update.
        APPEND VALUE #( %tky = ls_key-%tky
                        %param = CORRESPONDING #( ls_db MAPPING StoreId = store_id PhoneId = phone_id Brand = brand Model = model
                        Price = price StockCount = stock_count MaxCapacity = max_capacity SupplierId = supplier_id
                        ImageUrl = image_url DeliveryModel = delivery_model PaymentStatus = payment_status
                        InvoiceStatus = invoice_status ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD payWithGPay.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zmb_inv_u_083 WHERE store_id = @ls_key-StoreId AND phone_id = @ls_key-PhoneId INTO @DATA(ls_db).
      IF sy-subrc = 0.
        ls_db-payment_status = 'PAID'.
        ls_db-payment_method = 'GPAY'.
        APPEND ls_db TO lcl_buffer=>mt_update.
        APPEND VALUE #( %tky = ls_key-%tky
                        %param = CORRESPONDING #( ls_db MAPPING StoreId = store_id PhoneId = phone_id Brand = brand Model = model
                        Price = price StockCount = stock_count MaxCapacity = max_capacity SupplierId = supplier_id
                        ImageUrl = image_url DeliveryModel = delivery_model PaymentStatus = payment_status
                        InvoiceStatus = invoice_status ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD applyDiscount.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zmb_inv_u_083 WHERE store_id = @ls_key-StoreId AND phone_id = @ls_key-PhoneId INTO @DATA(ls_db).
      IF sy-subrc = 0.
        ls_db-price = ls_db-price - ( ls_db-price * ( ls_key-%param-discount_pct / 100 ) ).
        APPEND ls_db TO lcl_buffer=>mt_update.
        APPEND VALUE #( %tky = ls_key-%tky
                        %param = CORRESPONDING #( ls_db MAPPING StoreId = store_id PhoneId = phone_id Brand = brand Model = model
                        Price = price StockCount = stock_count MaxCapacity = max_capacity SupplierId = supplier_id
                        ImageUrl = image_url DeliveryModel = delivery_model PaymentStatus = payment_status
                        InvoiceStatus = invoice_status ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

" ---------------------------------------------------------------------
" 3. SAVER CLASS
" ---------------------------------------------------------------------
CLASS lsc_ZI_MOBINV_U_083 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_MOBINV_U_083 IMPLEMENTATION.
  METHOD save.
    IF lcl_buffer=>mt_insert IS NOT INITIAL. INSERT zmb_inv_u_083 FROM TABLE @lcl_buffer=>mt_insert. ENDIF.
    IF lcl_buffer=>mt_update IS NOT INITIAL. UPDATE zmb_inv_u_083 FROM TABLE @lcl_buffer=>mt_update. ENDIF.
    IF lcl_buffer=>mt_delete IS NOT INITIAL. DELETE zmb_inv_u_083 FROM TABLE @lcl_buffer=>mt_delete. ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>mt_insert, lcl_buffer=>mt_update, lcl_buffer=>mt_delete.
  ENDMETHOD.
ENDCLASS.
