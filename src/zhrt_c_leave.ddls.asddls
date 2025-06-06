@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave projection view'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZHRT_C_LEAVE
  provider contract transactional_query
  as projection on ZHRT_I_LEAVE
{
  key LeaveGuid,
      @ObjectModel.text.element: [ 'RequestorName' ]
      RequestorId,
      RequestorName,
      @ObjectModel.text.element: [ 'LeaveTypeDescription' ]
      LeaveTypeId,
      _LeaveType.Description as LeaveTypeDescription,
      @ObjectModel.text.element: [ 'StatusDescription' ]
      Status,
      _StatusDomain.Description as StatusDescription,
      DateFrom,
      DateTo,
      @ObjectModel.text.element: [ 'BackupName' ]
      BackupId,
      BackupName,
      RequestorComment,
      @ObjectModel.text.element: [ 'ApproverName' ]
      ApproverId,
      ApproverName,
      ApproverComment,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Approver,
      _Contacts : redirected to composition child ZHRT_C_LEAVE_CONT,
      _LeaveType,
      _Requestor,
      _StatusDomain
}
