@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave contacts interface view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZHRT_I_LEAVE_CONT
  as select from ZHRT_LEAVE_CONT
  association to parent ZHRT_I_LEAVE as _Leave on $projection.LeaveGuid = _Leave.LeaveGuid
{
  key leave_guid as LeaveGuid,
  key contact_nr as ContactNr,
      full_name  as FullName,
      email      as Email,
      _Leave // Make association public
}
