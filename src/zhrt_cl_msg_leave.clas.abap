CLASS zhrt_cl_msg_leave DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF role_not_existing,
        msgid TYPE symsgid VALUE 'ZHRT_LEAVE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF role_not_existing.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .


    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        attr1     TYPE string OPTIONAL
        attr2     TYPE string OPTIONAL
        severity  TYPE if_abap_behv_message=>t_severity OPTIONAL.

    DATA:
      mv_attr1 TYPE string,
      mv_attr2 TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.


ENDCLASS.



CLASS zhrt_cl_msg_leave IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).

    CLEAR me->textid.

    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.



    if_abap_behv_message~m_severity = severity.

    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.



ENDCLASS.
