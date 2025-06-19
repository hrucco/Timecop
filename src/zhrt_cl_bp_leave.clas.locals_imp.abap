 CLASS lhc_ZHRT_I_LEAVE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zhrt_i_leave RESULT result.
    METHODS suggestbackup FOR MODIFY
      IMPORTING keys FOR ACTION zhrt_i_leave~suggestbackup RESULT result.
    METHODS copyleave FOR MODIFY
      IMPORTING keys FOR ACTION zhrt_i_leave~copyleave.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zhrt_i_leave RESULT result.
    METHODS earlynumbering_cba_contacts FOR NUMBERING
      IMPORTING entities FOR CREATE zhrt_i_leave\_contacts.

ENDCLASS.

CLASS lhc_ZHRT_I_LEAVE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_cba_Contacts.



*" Coding alternativo, funciona solo suponiendo que creamos contactos de un solo Leave
*" y que el leave ya fue creado previamente
    DATA: lt_input_keys TYPE TABLE FOR READ IMPORT zhrt_i_leave\_Contacts,
          ls_input_keys TYPE STRUCTURE FOR READ IMPORT zhrt_i_leave\_Contacts,
          lt_result     TYPE TABLE FOR READ RESULT zhrt_i_leave\_Contacts,
          lt_link       TYPE TABLE FOR READ LINK zhrt_i_leave\_Contacts.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>).

      ls_input_keys-%key = <ls_entities>-%key .

      APPEND ls_input_keys TO lt_input_keys.

    ENDLOOP.

    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
     ENTITY zhrt_i_leave BY \_Contacts
     FROM lt_input_keys
*"     RESULT lt_result
     LINK lt_link.

*" Esta mal porque falta agrupdar por leaveguid para el caso que se creeen contactos en diferentes leaves
    DATA: lv_max_aux TYPE zhrt_leave_cont-contact_nr.

    LOOP AT lt_link ASSIGNING FIELD-SYMBOL(<ls_link>).

      IF <ls_link>-target-ContactNr > lv_max_aux.

        lv_max_aux = <ls_link>-target-ContactNr.

      ENDIF.

    ENDLOOP.


    DATA: ls_map_leave_cont TYPE STRUCTURE FOR MAPPED EARLY zhrt_i_leave_cont.

* Esta mal porque no contempla los casos en que se esta creando el leave junto con el contact
*" y porque supone un solo travel
    LOOP AT entities ASSIGNING <ls_entities>.



      LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_target>).

        lv_max_aux += 1.

        ls_map_leave_cont-%cid      = <ls_target>-%cid.
        ls_map_leave_cont-LeaveGuid = <ls_target>-LeaveGuid.
        ls_map_leave_cont-ContactNr = lv_max_aux.


        APPEND ls_map_leave_cont TO mapped-zhrt_i_leave_cont.

      ENDLOOP.

    ENDLOOP.



* CASO CORRECTO
*    DATA : lv_max_contact TYPE zhrt_leave_cont-contact_nr.
*
** leer todos los contactos del leave
*    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
*     ENTITY zhrt_i_leave BY \_Contacts
*     FROM CORRESPONDING #( entities )
*     LINK DATA(lt_link_data).
*
** obtener el ultimo ID
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
*                               GROUP BY <ls_group_entity>-LeaveGuid.
*
*
*      lv_max_contact = REDUCE #( INIT lv_max = CONV zhrt_leave_cont-contact_nr( '0' )
*                                 FOR ls_link IN lt_link_data USING KEY entity
*                                      WHERE ( source-LeaveGuid = <ls_group_entity>-LeaveGuid  )
*                                 NEXT  lv_max = COND  zhrt_leave_cont-contact_nr( WHEN lv_max < ls_link-target-ContactNr
*                                                                       THEN ls_link-target-ContactNr
*                                                                        ELSE lv_max ) ).
*      lv_max_contact  = REDUCE #( INIT lv_max = lv_max_contact
*                                   FOR ls_entity IN entities USING KEY entity
*                                       WHERE ( LeaveGuid = <ls_group_entity>-LeaveGuid  )
*                                     FOR ls_contact IN ls_entity-%target
*                                     NEXT lv_max = COND  zhrt_leave_cont-contact_nr( WHEN lv_max < ls_contact-ContactNr
*                                                                        THEN ls_contact-ContactNr
*                                                                         ELSE lv_max )
*       ).
*
** sumar 1
** actualizar la mapped
*      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
*                        USING KEY entity
*                         WHERE LeaveGuid = <ls_group_entity>-LeaveGuid.
*
*        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_contact>).
*          APPEND CORRESPONDING #( <ls_contact> )  TO   mapped-zhrt_i_leave_cont
*             ASSIGNING FIELD-SYMBOL(<ls_new_map_contact>).
*          IF <ls_contact>-ContactNr IS INITIAL.
*            lv_max_contact += 1.
*
*
*            <ls_new_map_contact>-ContactNr = lv_max_contact.
*          ENDIF.
*
*        ENDLOOP.
*
*
*
*      ENDLOOP.
*
*    ENDLOOP.


  ENDMETHOD.


  METHOD suggestBackup.

*" FRAMEWORK
    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
      ENTITY zhrt_i_leave
      FIELDS ( RequestorId BackupId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requestors)
      FAILED DATA(lt_failed).

    IF lt_failed IS NOT INITIAL.
*" errror
*" exit
    ENDIF.

*" LOGCA de NEGOCIO
*" Get assigned employees
    DATA(lt_req_with_no_backup) = lt_requestors.

    DELETE lt_req_with_no_backup WHERE BackupId IS NOT INITIAL.

    SELECT employee_id, role
     FROM zhrt_employee
     FOR ALL ENTRIES IN @lt_req_with_no_backup
     WHERE employee_id = @lt_req_with_no_backup-RequestorId
     INTO TABLE @DATA(lt_requestor_roles).

    IF sy-subrc NE 0.



      LOOP AT lt_req_with_no_backup
      ASSIGNING FIELD-SYMBOL(<ls_req_with_no_backup>).

        DO 3 TIMES.
        APPEND VALUE #( leaveguid = <ls_req_with_no_backup>-LeaveGuid
*"                        %update = if_abap_behv=>mk-on
*"                        %action-suggestbackup = if_abap_behv=>mk-on
                        %element-backupid = if_abap_behv=>mk-on

                        %global = if_abap_behv=>mk-on
                        %msg = NEW zhrt_cl_msg_leave(
                                                      textid = VALUE #( msgid = 'ZHRT_LEAVE'
                                                                        msgno = '001'
                                                                        attr1 = 'MV_ATTR1'
                                                                        attr2 = 'MV_ATTR2'
                                                      )
                                                      attr1 = CONV #( <ls_req_with_no_backup>-RequestorId )
                                                      attr2 = CONV #( 'has no role'  )

                                                   severity = if_abap_behv_message=>severity-error )
                       ) TO reported-zhrt_i_leave.

        ENDDO.

        RETURN.

      ENDLOOP.


    ENDIF.

    DATA(system_date) = cl_abap_context_info=>get_system_date( ).


    SELECT zhrt_employee~employee_id, zhrt_employee~role
    FROM zhrt_employee
    INNER JOIN zhrt_assignment
    ON zhrt_employee~employee_id = zhrt_assignment~employee_id
    FOR ALL ENTRIES IN @lt_requestor_roles
    WHERE zhrt_employee~role = @lt_requestor_roles-role
    AND NOT ( zhrt_assignment~date_from LE @system_date
    AND zhrt_assignment~date_to GE @system_date )
    INTO TABLE @DATA(lt_tentative_backups).

    IF sy-subrc NE 0.
      " exit
    ENDIF.

    SORT lt_requestor_roles BY employee_id.

    SORT lt_tentative_backups BY role.

    LOOP AT lt_req_with_no_backup
      ASSIGNING <ls_req_with_no_backup>.

      READ TABLE lt_requestor_roles
        WITH KEY employee_id = <ls_req_with_no_backup>-RequestorId
        ASSIGNING FIELD-SYMBOL(<ls_requestor_roles>)
        BINARY SEARCH.

      IF sy-subrc EQ 0.

        READ TABLE lt_tentative_backups
         ASSIGNING FIELD-SYMBOL(<ls_backup>)
         WITH KEY role = <ls_requestor_roles>-role
         BINARY SEARCH.

        IF sy-subrc EQ 0.

          <ls_req_with_no_backup>-BackupId = <ls_backup>-employee_id.

        ENDIF.
*
      ENDIF.

    ENDLOOP.


*" FRAMEWORK
* si el backup no esta vacio mostrar un mensaje de error
*" si el backup esta vacio, buscar un empleado con el mismo rol que no este asignado

* cargar el empleado en el campo de backup
    MODIFY ENTITIES OF zhrt_i_leave IN LOCAL MODE
    ENTITY zhrt_i_leave
    UPDATE FIELDS ( BackupId )
    WITH VALUE #( FOR ls_req_with_no_backup
                   IN lt_req_with_no_backup ( %tky = ls_req_with_no_backup-%tky
                                              BackupId = ls_req_with_no_backup-BackupId )
                ).



    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
    ENTITY zhrt_i_leave
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).



  ENDMETHOD.


  METHOD copyLeave.


*" leer el leave a copiar
    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
      ENTITY zhrt_i_leave
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave)
      FAILED DATA(lt_failed).

    IF lt_failed IS NOT INITIAL.

      failed = lt_failed.

      return.

    ENDIF.

    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
      ENTITY zhrt_i_leave BY \_Contacts
      ALL FIELDS WITH CORRESPONDING #( lt_leave )
      RESULT DATA(lt_contacts)
      FAILED lt_failed.

    IF lt_failed IS NOT INITIAL.

      failed = lt_failed.

      return.

    ENDIF.

*" Actualizar el estado
    LOOP AT lt_leave ASSIGNING FIELD-SYMBOL(<ls_leave>).

        <ls_leave>-Status = 'P'. "Pending

    ENDLOOP.

    DATA: lt_create_leave TYPE TABLE FOR CREATE zhrt_i_leave,
          lt_create_contact TYPE TABLE FOR CREATE zhrt_i_leave\_Contacts.

    LOOP AT lt_leave ASSIGNING <ls_leave>.

        APPEND VALUE #( %cid = keys[ KEY id LeaveGuid = <ls_leave>-LeaveGuid ]-%cid
                        %data = CORRESPONDING #( <ls_leave>-%data EXCEPT LeaveGuid ) ) TO lt_create_leave.


        APPEND VALUE #( %cid_ref = keys[ KEY id LeaveGuid = <ls_leave>-LeaveGuid ]-%cid
                                                                       ) TO lt_create_contact
                                                                       ASSIGNING FIELD-SYMBOL(<ls_contact_header>).

        LOOP AT lt_contacts ASSIGNING FIELD-SYMBOL(<ls_contacts>)
          USING KEY id
          WHERE LeaveGuid = <ls_leave>-LeaveGuid.

            APPEND VALUE #( %cid  = <ls_contact_header>-%cid_ref && <ls_contacts>-ContactNr
                            %data = CORRESPONDING #( <ls_contacts>-%data EXCEPT LeaveGuid Contactnr ) )
             TO <ls_contact_header>-%target.


        ENDLOOP.

    ENDLOOP.



*" modify para crear el nuevo
    MODIFY ENTITIES OF zhrt_i_leave IN LOCAL MODE
    ENTITY zhrt_i_leave
    CREATE
    FIELDS ( RequestorId LeaveTypeId Status DateFrom
             DateTo BackupId )
    WITH lt_create_leave
    ENTITY zhrt_i_leave
    CREATE BY \_Contacts
    FIELDS ( Email FullName )
    WITH lt_create_contact
    MAPPED DATA(it_mapped).

    mapped-zhrt_i_leave = it_mapped-zhrt_i_leave.


  ENDMETHOD.

  METHOD get_instance_features.

     READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
     ENTITY zhrt_i_leave
     FIELDS ( LeaveGuid Status )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_leave).

    result  = VALUE #( FOR ls_leave IN lt_leave
                        (  %tky = ls_leave-%tky
                           %features-%action-copyLeave = COND #( WHEN ls_leave-Status = 'C'
                                                                    THEN if_abap_behv=>fc-o-enabled
                                                                    ELSE if_abap_behv=>fc-o-disabled )
                           %features-%assoc-_Contacts = COND #( WHEN ls_leave-Status = 'C'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled ) )
                   ).


  ENDMETHOD.

ENDCLASS.
