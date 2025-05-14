@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave types base view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZHRT_B_LEAVE_TYPE
  as select from zhrt_leave_type
{
  key leave_type_id      as LeaveTypeId,
      description        as Description,
      x_mand_attachments as XMandAttachments
}
