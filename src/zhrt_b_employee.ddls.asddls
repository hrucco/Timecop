@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employees base view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZHRT_B_EMPLOYEE
  as select from zhrt_employee
{
  key employee_id as EmployeeId,
      first_name  as FirstName,
      last_name   as LastName,
      email       as Email,
      role        as Role,
      x_approver  as XApprover
}
