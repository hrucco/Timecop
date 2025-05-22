@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'To read status domain values'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZHRT_I_STATUS_DOMAIN
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T(p_domain_name: 'ZHRT_STATUS')
{
  key language  as Language,
  key value_low as ValueLow,
      text      as Description
}
