CLASS lhc_ZHRT_I_LEAVE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zhrt_i_leave RESULT result.
    METHODS earlynumbering_cba_contacts FOR NUMBERING
      IMPORTING entities FOR CREATE zhrt_i_leave\_contacts.

ENDCLASS.

CLASS lhc_ZHRT_I_LEAVE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_cba_Contacts.


    DATA : lv_max_contact TYPE zhrt_leave_cont-contact_nr.

* leer todos los contactos del leave
    READ ENTITIES OF zhrt_i_leave IN LOCAL MODE
     ENTITY zhrt_i_leave BY \_Contacts
     FROM CORRESPONDING #( entities )
     LINK DATA(lt_link_data).

* obtener el ultimo ID
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
                               GROUP BY <ls_group_entity>-LeaveGuid.


      lv_max_contact = REDUCE #( INIT lv_max = CONV zhrt_leave_cont-contact_nr( '0' )
                                 FOR ls_link IN lt_link_data USING KEY entity
                                      WHERE ( source-LeaveGuid = <ls_group_entity>-LeaveGuid  )
                                 NEXT  lv_max = COND  zhrt_leave_cont-contact_nr( WHEN lv_max < ls_link-target-ContactNr
                                                                       THEN ls_link-target-ContactNr
                                                                        ELSE lv_max ) ).
      lv_max_contact  = REDUCE #( INIT lv_max = lv_max_contact
                                   FOR ls_entity IN entities USING KEY entity
                                       WHERE ( LeaveGuid = <ls_group_entity>-LeaveGuid  )
                                     FOR ls_contact IN ls_entity-%target
                                     NEXT lv_max = COND  zhrt_leave_cont-contact_nr( WHEN lv_max < ls_contact-ContactNr
                                                                        THEN ls_contact-ContactNr
                                                                         ELSE lv_max )
       ).

* sumar 1
* actualizar la mapped
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
                        USING KEY entity
                         WHERE LeaveGuid = <ls_group_entity>-LeaveGuid.

        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_contact>).
          APPEND CORRESPONDING #( <ls_contact> )  TO   mapped-zhrt_i_leave_cont
             ASSIGNING FIELD-SYMBOL(<ls_new_map_contact>).
          IF <ls_contact>-ContactNr IS INITIAL.
            lv_max_contact += 1.


            <ls_new_map_contact>-ContactNr = lv_max_contact.
          ENDIF.

        ENDLOOP.



      ENDLOOP.

    ENDLOOP.





  ENDMETHOD.

ENDCLASS.
