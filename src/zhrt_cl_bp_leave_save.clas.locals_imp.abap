CLASS lsc_ZHRT_I_LEAVE DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZHRT_I_LEAVE IMPLEMENTATION.

  METHOD save_modified.

    DATA: ls_timecop_log TYPE zhrt_timecop_log,
          lt_timecop_log TYPE STANDARD TABLE OF zhrt_timecop_log.

    FIELD-SYMBOLS: <lt_leave_tab>      TYPE ANY TABLE,
                   <lt_leave_cont_tab> TYPE ANY TABLE.


    ls_timecop_log-utclong = utclong_current( ).
    ls_timecop_log-log_user = sy-uname.

    IF create-zhrt_i_leave IS NOT INITIAL.

      ls_timecop_log-operation = 'C'.

      ASSIGN create-zhrt_i_leave TO <lt_leave_tab>.

    ELSEIF update-zhrt_i_leave IS NOT INITIAL.

      ls_timecop_log-operation = 'U'.

      ASSIGN update-zhrt_i_leave TO <lt_leave_tab>.

    ELSEIF delete-zhrt_i_leave IS NOT INITIAL.

      ls_timecop_log-operation = 'D'.

      ASSIGN delete-zhrt_i_leave TO <lt_leave_tab>.

    ENDIF.

    IF <lt_leave_tab> IS ASSIGNED.

        LOOP AT <lt_leave_tab> ASSIGNING FIELD-SYMBOL(<ls_leave>).

          ls_timecop_log-counter += 1.

          ASSIGN COMPONENT 'LEAVEGUID' OF STRUCTURE <ls_leave> TO FIELD-SYMBOL(<lv_leaveguid>).

          IF <lv_leaveguid> IS ASSIGNED.

            ls_timecop_log-leave_guid = <lv_leaveguid>.

          ENDIF.

          APPEND ls_timecop_log TO lt_timecop_log.

        ENDLOOP.

      ENDIF.


     IF create-zhrt_i_leave_cont IS NOT INITIAL.

      ls_timecop_log-operation = 'C'.

      ASSIGN create-zhrt_i_leave_cont TO <lt_leave_cont_tab>.

    ELSEIF update-zhrt_i_leave_cont IS NOT INITIAL.

      ls_timecop_log-operation = 'U'.

      ASSIGN update-zhrt_i_leave_cont TO <lt_leave_cont_tab>.

    ELSEIF delete-zhrt_i_leave_cont IS NOT INITIAL.

      ls_timecop_log-operation = 'D'.

      ASSIGN delete-zhrt_i_leave_cont TO <lt_leave_cont_tab>.

    ENDIF.



      IF <lt_leave_cont_tab> IS ASSIGNED.

        LOOP AT <lt_leave_cont_tab> ASSIGNING FIELD-SYMBOL(<ls_leave_cont>).

          ls_timecop_log-counter += 1.

          ASSIGN COMPONENT 'LEAVEGUID' OF STRUCTURE <ls_leave_cont> TO <lv_leaveguid>.
          ASSIGN COMPONENT 'CONTACTNR' OF STRUCTURE <ls_leave_cont> TO FIELD-SYMBOL(<lv_contactnr>).

          IF <lv_leaveguid> IS ASSIGNED
          AND <lv_contactnr> IS ASSIGNED.

            ls_timecop_log-leave_guid = <lv_leaveguid>.
            ls_timecop_log-contact_nr = <lv_contactnr>.

          ENDIF.

          APPEND ls_timecop_log TO lt_timecop_log.

        ENDLOOP.

      ENDIF.

      INSERT zhrt_timecop_log FROM TABLE @lt_timecop_log.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
