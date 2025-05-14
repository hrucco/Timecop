@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave projection view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZHRT_C_LEAVE
  provider contract transactional_query
 as projection on ZHRT_I_LEAVE
{
    key LeaveGuid,
    RequestorId,
    LeaveTypeId,
    Status,
    DateFrom,
    DateTo,
    RequestorComment,
    ApproverId,
    ApproverComment,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Approver,
    _Contacts : redirected to composition child ZHRT_C_LEAVE_CONT,
    _LeaveType,
    _Requestor
}
