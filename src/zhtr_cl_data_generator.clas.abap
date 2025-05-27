CLASS zhtr_cl_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhtr_cl_data_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " delete existing entries in the database table
    DELETE FROM zhrt_assignment.
    DELETE FROM zhrt_employee.
    DELETE FROM zhrt_leave.
    "DELETE FROM zhrt_leave_cont.
    DELETE FROM zhrt_leave_type.
    COMMIT WORK.

    DATA: lt_employee TYPE STANDARD TABLE OF zhrt_employee,
          lv_uuid1    TYPE zhrt_employee-employee_id,
          lv_uuid2    TYPE zhrt_employee-employee_id,
          lv_uuid3    TYPE zhrt_employee-employee_id,
          lv_uuid4    TYPE zhrt_employee-employee_id.

    TRY.
        lv_uuid1 =  cl_system_uuid=>create_uuid_x16_static(  ).
        lv_uuid2 =  cl_system_uuid=>create_uuid_x16_static(  ).
        lv_uuid3 =  cl_system_uuid=>create_uuid_x16_static(  ).
        lv_uuid4 =  cl_system_uuid=>create_uuid_x16_static(  ).
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.


    lt_employee = VALUE #( ( employee_id = lv_uuid1 first_name = 'Juan' last_name = 'Perez' email = 'jp@gmail.com' role = 'TECH' x_approver = 'X' )
                           ( employee_id = lv_uuid2 first_name = 'Alfredo' last_name = 'Gimenez' email = 'ag@gmail.com' role = 'FUNC' x_approver = '' )
                           ( employee_id = lv_uuid3 first_name = 'Florencia' last_name = 'Amato' email = 'fa@gmail.com' role = 'T&F' x_approver = '' )
                           ( employee_id = lv_uuid4 first_name = 'Ricardo' last_name = 'Lopez' email = 'rl@gmail.com' role = 'ADM' x_approver = 'X' )
    ).


    INSERT zhrt_employee FROM TABLE @lt_employee.

    COMMIT WORK.


    DATA lt_assig TYPE STANDARD TABLE OF zhrt_assignment.

    lt_assig = VALUE #( ( employee_id = lv_uuid1 date_from = '20240101' date_to = '20250101' customer = 'INTERNAL' )
                        ( employee_id = lv_uuid1 date_from = '20250102' date_to = '20260101' customer = 'PG' )
                        ( employee_id = lv_uuid2 date_from = '20240101' date_to = '20260101' customer = 'ARBA' )
                        ( employee_id = lv_uuid4 date_from = '20240101' date_to = '20250101' customer = 'PG' )
    ).


    INSERT zhrt_assignment FROM TABLE @lt_assig.

    COMMIT WORK.

    DATA lt_ltype TYPE STANDARD TABLE OF zhrt_leave_type.

    lt_ltype = VALUE #( ( leave_type_id = 'MED' description = 'Medical' x_mand_attachments = 'X'  )
                        ( leave_type_id = 'EXAM' description = 'Exam' x_mand_attachments = 'X'  )
                        ( leave_type_id = 'PERS' description = 'Personal' x_mand_attachments = ''  )
    ).


    INSERT zhrt_leave_type FROM TABLE @lt_ltype.

    COMMIT WORK.

    DATA lt_leave TYPE STANDARD TABLE OF zhrt_leave.

    TRY.
        lt_leave = VALUE #( ( leave_guid = cl_system_uuid=>create_uuid_x16_static(  )
                              requestor_id = lv_uuid1
                              leave_type_id = 'MED'
                              status = 'A'
                              date_from = '20250101'
                              date_to = '20250101'
                              requestor_comment = 'Medical exam'
                              approver_id = lv_uuid4
                              approver_comment = 'App by me'
                                ) ).
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    INSERT zhrt_leave FROM TABLE @lt_leave.

    COMMIT WORK.

    out->write( 'data inserted.' ).


  ENDMETHOD.

ENDCLASS.
