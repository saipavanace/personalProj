//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may 
// only be used by a person authorised under and to the extent permitted 
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file 
// and copies of this file may only be made by a person if such person is 
// permitted to do so under the terms of a subsisting license agreement 
// from ARM Limited.
//
//----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Revision       : 175006
//
//  Date                :  2014-06-18 17:27:30 +0100 (Wed, 18 Jun 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------

`ifndef CHI5PC_CHI5_DEFINES_V
`define CHI5PC_CHI5_DEFINES_V

//=========================================================================
//


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

// SIGNAL CHI5PC_REQ_FLIT
`define CHI5PC_REQ_FLIT_WIDTH          121
`define CHI5PC_REQ_FLIT_MSB            120
`define CHI5PC_REQ_FLIT_LSB            0
`define CHI5PC_REQ_FLIT_RANGE          120:0

// SIGNAL CHI5PC_RSP_FLIT
`define CHI5PC_RSP_FLIT_WIDTH          45
`define CHI5PC_RSP_FLIT_MSB            44
`define CHI5PC_RSP_FLIT_LSB            0
`define CHI5PC_RSP_FLIT_RANGE          44:0

// SIGNAL CHI5PC_SNP_FLIT
`define CHI5PC_SNP_FLIT_WIDTH          73
`define CHI5PC_SNP_FLIT_MSB            72
`define CHI5PC_SNP_FLIT_LSB            0
`define CHI5PC_SNP_FLIT_RANGE          72:0

// SIGNAL CHI5PC_128B_DAT_FLIT
`define CHI5PC_128B_DAT_FLIT_WIDTH          190 + DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_MSB            189 + DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_LSB            0
`define CHI5PC_128B_DAT_FLIT_RANGE          189 + DAT_RSVDC_WIDTH:0

// SIGNAL CHI5PC_256B_DAT_FLIT
`define CHI5PC_256B_DAT_FLIT_WIDTH          334 + DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_MSB            333 + DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_LSB            0
`define CHI5PC_256B_DAT_FLIT_RANGE          333 + DAT_RSVDC_WIDTH:0

// SIGNAL CHI5PC_512B_DAT_FLIT
`define CHI5PC_512B_DAT_FLIT_WIDTH          622 + DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_MSB            621 + DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_LSB            0
`define CHI5PC_512B_DAT_FLIT_RANGE          621 + DAT_RSVDC_WIDTH:0

// START OF BUS CHI5PC_REQ_FLIT
`define CHI5PC_REQ_FLIT_QOS_WIDTH          4
`define CHI5PC_REQ_FLIT_QOS_MSB            3
`define CHI5PC_REQ_FLIT_QOS_LSB            0
`define CHI5PC_REQ_FLIT_QOS_RANGE          3:0

`define CHI5PC_REQ_FLIT_TGTID_WIDTH          7
`define CHI5PC_REQ_FLIT_TGTID_MSB            10
`define CHI5PC_REQ_FLIT_TGTID_LSB            4
`define CHI5PC_REQ_FLIT_TGTID_RANGE          10:4

`define CHI5PC_REQ_FLIT_SRCID_WIDTH          7
`define CHI5PC_REQ_FLIT_SRCID_MSB            17
`define CHI5PC_REQ_FLIT_SRCID_LSB            11
`define CHI5PC_REQ_FLIT_SRCID_RANGE          17:11

`define CHI5PC_REQ_FLIT_TXNID_WIDTH          8
`define CHI5PC_REQ_FLIT_TXNID_MSB            25
`define CHI5PC_REQ_FLIT_TXNID_LSB            18
`define CHI5PC_REQ_FLIT_TXNID_RANGE          25:18

//missing returnnid(7bits), stashnidvalid(1bit) and returntxnid(8bit)
`define CHI5PC_REQ_FLIT_OPCODE_WIDTH          6
`define CHI5PC_REQ_FLIT_OPCODE_MSB            47
`define CHI5PC_REQ_FLIT_OPCODE_LSB            42
`define CHI5PC_REQ_FLIT_OPCODE_RANGE          47:42

`define CHI5PC_REQ_FLIT_SIZE_WIDTH          3
`define CHI5PC_REQ_FLIT_SIZE_MSB            50
`define CHI5PC_REQ_FLIT_SIZE_LSB            48
`define CHI5PC_REQ_FLIT_SIZE_RANGE          50:48

`define CHI5PC_REQ_FLIT_ADDR_WIDTH          48
`define CHI5PC_REQ_FLIT_ADDR_MSB            98
`define CHI5PC_REQ_FLIT_ADDR_LSB            51
`define CHI5PC_REQ_FLIT_ADDR_RANGE          98:51

`define CHI5PC_REQ_FLIT_NS_WIDTH          1
`define CHI5PC_REQ_FLIT_NS_MSB            99
`define CHI5PC_REQ_FLIT_NS_LSB            99
`define CHI5PC_REQ_FLIT_NS_RANGE          99

`define CHI5PC_REQ_FLIT_LIKELYSHARED_WIDTH          1
`define CHI5PC_REQ_FLIT_LIKELYSHARED_MSB            100
`define CHI5PC_REQ_FLIT_LIKELYSHARED_LSB            100
`define CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE          100

`define CHI5PC_REQ_FLIT_DYNPCRD_WIDTH          1
`define CHI5PC_REQ_FLIT_DYNPCRD_MSB            101
`define CHI5PC_REQ_FLIT_DYNPCRD_LSB            101
`define CHI5PC_REQ_FLIT_DYNPCRD_RANGE          101

`define CHI5PC_REQ_FLIT_ORDER_WIDTH          2
`define CHI5PC_REQ_FLIT_ORDER_MSB            103
`define CHI5PC_REQ_FLIT_ORDER_LSB            102
`define CHI5PC_REQ_FLIT_ORDER_RANGE          103:102

`define CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH          4
`define CHI5PC_REQ_FLIT_PCRDTYPE_MSB            107
`define CHI5PC_REQ_FLIT_PCRDTYPE_LSB            104
`define CHI5PC_REQ_FLIT_PCRDTYPE_RANGE          107:104

`define CHI5PC_REQ_FLIT_MEMATTR_WIDTH          4
`define CHI5PC_REQ_FLIT_MEMATTR_MSB            111
`define CHI5PC_REQ_FLIT_MEMATTR_LSB            108
`define CHI5PC_REQ_FLIT_MEMATTR_RANGE          111:108

`define CHI5PC_REQ_FLIT_MEMATTR_EARLYWRACK_WIDTH          1
`define CHI5PC_REQ_FLIT_MEMATTR_EARLYWRACK_MSB            108 
`define CHI5PC_REQ_FLIT_MEMATTR_EARLYWRACK_LSB            108 
`define CHI5PC_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE          108 

`define CHI5PC_REQ_FLIT_MEMATTR_DEVICE_WIDTH          1
`define CHI5PC_REQ_FLIT_MEMATTR_DEVICE_MSB           109 
`define CHI5PC_REQ_FLIT_MEMATTR_DEVICE_LSB           109 
`define CHI5PC_REQ_FLIT_MEMATTR_DEVICE_RANGE         109 

`define CHI5PC_REQ_FLIT_MEMATTR_CACHEABLE_WIDTH          1
`define CHI5PC_REQ_FLIT_MEMATTR_CACHEABLE_MSB            110 
`define CHI5PC_REQ_FLIT_MEMATTR_CACHEABLE_LSB            110 
`define CHI5PC_REQ_FLIT_MEMATTR_CACHEABLE_RANGE          110 

`define CHI5PC_REQ_FLIT_MEMATTR_ALLOCATE_WIDTH          1
`define CHI5PC_REQ_FLIT_MEMATTR_ALLOCATE_MSB            111 
`define CHI5PC_REQ_FLIT_MEMATTR_ALLOCATE_LSB            111 
`define CHI5PC_REQ_FLIT_MEMATTR_ALLOCATE_RANGE          111 

`define CHI5PC_REQ_FLIT_SNPATTR_WIDTH          2
`define CHI5PC_REQ_FLIT_SNPATTR_MSB            113
`define CHI5PC_REQ_FLIT_SNPATTR_LSB            112
`define CHI5PC_REQ_FLIT_SNPATTR_RANGE          113:112

`define CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_WIDTH          1
`define CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_MSB            112
`define CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_LSB            112
`define CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE          112

`define CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_WIDTH          1
`define CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_MSB            113
`define CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_LSB            113
`define CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE          113

`define CHI5PC_REQ_FLIT_LPID_WIDTH          5
`define CHI5PC_REQ_FLIT_LPID_MSB            118
`define CHI5PC_REQ_FLIT_LPID_LSB            114
`define CHI5PC_REQ_FLIT_LPID_RANGE          118:114

`define CHI5PC_REQ_FLIT_EXCL_WIDTH          1
`define CHI5PC_REQ_FLIT_EXCL_MSB            119
`define CHI5PC_REQ_FLIT_EXCL_LSB            119
`define CHI5PC_REQ_FLIT_EXCL_RANGE          119

`define CHI5PC_REQ_FLIT_EXPCOMPACK_WIDTH          1
`define CHI5PC_REQ_FLIT_EXPCOMPACK_MSB            120
`define CHI5PC_REQ_FLIT_EXPCOMPACK_LSB            120
`define CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE          120

//`define CHI5PC_REQ_FLIT_RSVDC_WIDTH          4
`define CHI5PC_REQ_FLIT_RSVDC_MSB            96+REQ_RSVDC_WIDTH
`define CHI5PC_REQ_FLIT_RSVDC_LSB            96
`define CHI5PC_REQ_FLIT_RSVDC_RANGE          'CHI5PC_REQ_FLIT_RSVDC_MSB:96
// END OF BUS CHI5PC_REQ_FLIT

// START OF BUS CHI5PC_RSP_FLIT
`define CHI5PC_RSP_FLIT_QOS_WIDTH          4
`define CHI5PC_RSP_FLIT_QOS_MSB            3
`define CHI5PC_RSP_FLIT_QOS_LSB            0
`define CHI5PC_RSP_FLIT_QOS_RANGE          3:0

`define CHI5PC_RSP_FLIT_TGTID_WIDTH          7
`define CHI5PC_RSP_FLIT_TGTID_MSB            10
`define CHI5PC_RSP_FLIT_TGTID_LSB            4
`define CHI5PC_RSP_FLIT_TGTID_RANGE          10:4

`define CHI5PC_RSP_FLIT_SRCID_WIDTH          7
`define CHI5PC_RSP_FLIT_SRCID_MSB            17
`define CHI5PC_RSP_FLIT_SRCID_LSB            11
`define CHI5PC_RSP_FLIT_SRCID_RANGE          17:11

`define CHI5PC_RSP_FLIT_TXNID_WIDTH          8
`define CHI5PC_RSP_FLIT_TXNID_MSB            25
`define CHI5PC_RSP_FLIT_TXNID_LSB            18
`define CHI5PC_RSP_FLIT_TXNID_RANGE          25:18

`define CHI5PC_RSP_FLIT_OPCODE_WIDTH          4
`define CHI5PC_RSP_FLIT_OPCODE_MSB            29
`define CHI5PC_RSP_FLIT_OPCODE_LSB            26
`define CHI5PC_RSP_FLIT_OPCODE_RANGE          29:26

`define CHI5PC_RSP_FLIT_RESPERR_WIDTH          2
`define CHI5PC_RSP_FLIT_RESPERR_MSB            31
`define CHI5PC_RSP_FLIT_RESPERR_LSB            30
`define CHI5PC_RSP_FLIT_RESPERR_RANGE          31:30

`define CHI5PC_RSP_FLIT_RESP_WIDTH          3
`define CHI5PC_RSP_FLIT_RESP_MSB            34
`define CHI5PC_RSP_FLIT_RESP_LSB            32
`define CHI5PC_RSP_FLIT_RESP_RANGE          34:32

`define CHI5PC_RSP_FLIT_DBID_WIDTH          8
`define CHI5PC_RSP_FLIT_DBID_MSB            42
`define CHI5PC_RSP_FLIT_DBID_LSB            35
`define CHI5PC_RSP_FLIT_DBID_RANGE          42:35

`define CHI5PC_RSP_FLIT_PCRDTYPE_WIDTH          2
`define CHI5PC_RSP_FLIT_PCRDTYPE_MSB            44
`define CHI5PC_RSP_FLIT_PCRDTYPE_LSB            43
`define CHI5PC_RSP_FLIT_PCRDTYPE_RANGE          44:43
// END OF BUS CHI5PC_RSP_FLIT

// START OF BUS CHI5PC_SNP_FLIT
`define CHI5PC_SNP_FLIT_QOS_WIDTH          4
`define CHI5PC_SNP_FLIT_QOS_MSB            3
`define CHI5PC_SNP_FLIT_QOS_LSB            0
`define CHI5PC_SNP_FLIT_QOS_RANGE          3:0

`define CHI5PC_SNP_FLIT_SRCID_WIDTH          7
`define CHI5PC_SNP_FLIT_SRCID_MSB            10
`define CHI5PC_SNP_FLIT_SRCID_LSB            4
`define CHI5PC_SNP_FLIT_SRCID_RANGE          10:4

`define CHI5PC_SNP_FLIT_TXNID_WIDTH          8
`define CHI5PC_SNP_FLIT_TXNID_MSB            18
`define CHI5PC_SNP_FLIT_TXNID_LSB            11
`define CHI5PC_SNP_FLIT_TXNID_RANGE          18:11

`define CHI5PC_SNP_FLIT_OPCODE_WIDTH          5
`define CHI5PC_SNP_FLIT_OPCODE_MSB            23
`define CHI5PC_SNP_FLIT_OPCODE_LSB            19
`define CHI5PC_SNP_FLIT_OPCODE_RANGE          23:19

`define CHI5PC_SNP_FLIT_ADDR_WIDTH          48
`define CHI5PC_SNP_FLIT_ADDR_MSB            71
`define CHI5PC_SNP_FLIT_ADDR_LSB            24
`define CHI5PC_SNP_FLIT_ADDR_RANGE          71:24

`define CHI5PC_SNP_FLIT_NS_WIDTH          1
`define CHI5PC_SNP_FLIT_NS_MSB            72
`define CHI5PC_SNP_FLIT_NS_LSB            72
`define CHI5PC_SNP_FLIT_NS_RANGE          72
// END OF BUS CHI5PC_SNP_FLIT

// START OF BUS CHI5PC_DAT_FLIT
`define CHI5PC_DAT_FLIT_QOS_WIDTH          4
`define CHI5PC_DAT_FLIT_QOS_MSB            3
`define CHI5PC_DAT_FLIT_QOS_LSB            0
`define CHI5PC_DAT_FLIT_QOS_RANGE          3:0

`define CHI5PC_DAT_FLIT_TGTID_WIDTH          7
`define CHI5PC_DAT_FLIT_TGTID_MSB            10
`define CHI5PC_DAT_FLIT_TGTID_LSB            4
`define CHI5PC_DAT_FLIT_TGTID_RANGE          10:4

`define CHI5PC_DAT_FLIT_SRCID_WIDTH          7
`define CHI5PC_DAT_FLIT_SRCID_MSB            17
`define CHI5PC_DAT_FLIT_SRCID_LSB            11
`define CHI5PC_DAT_FLIT_SRCID_RANGE          17:11

`define CHI5PC_DAT_FLIT_TXNID_WIDTH          8
`define CHI5PC_DAT_FLIT_TXNID_MSB            25
`define CHI5PC_DAT_FLIT_TXNID_LSB            18
`define CHI5PC_DAT_FLIT_TXNID_RANGE          25:18

`define CHI5PC_DAT_FLIT_OPCODE_WIDTH          3
`define CHI5PC_DAT_FLIT_OPCODE_MSB            28
`define CHI5PC_DAT_FLIT_OPCODE_LSB            26
`define CHI5PC_DAT_FLIT_OPCODE_RANGE          28:26

`define CHI5PC_DAT_FLIT_RESPERR_WIDTH          2
`define CHI5PC_DAT_FLIT_RESPERR_MSB            30
`define CHI5PC_DAT_FLIT_RESPERR_LSB            29
`define CHI5PC_DAT_FLIT_RESPERR_RANGE          30:29

`define CHI5PC_DAT_FLIT_RESP_WIDTH          3
`define CHI5PC_DAT_FLIT_RESP_MSB            33
`define CHI5PC_DAT_FLIT_RESP_LSB            31
`define CHI5PC_DAT_FLIT_RESP_RANGE          33:31

`define CHI5PC_DAT_FLIT_DBID_WIDTH          8
`define CHI5PC_DAT_FLIT_DBID_MSB            41
`define CHI5PC_DAT_FLIT_DBID_LSB            34
`define CHI5PC_DAT_FLIT_DBID_RANGE          41:34

`define CHI5PC_DAT_FLIT_CCID_WIDTH          2
`define CHI5PC_DAT_FLIT_CCID_MSB            43
`define CHI5PC_DAT_FLIT_CCID_LSB            42
`define CHI5PC_DAT_FLIT_CCID_RANGE          43:42

`define CHI5PC_DAT_FLIT_DATAID_WIDTH          2
`define CHI5PC_DAT_FLIT_DATAID_MSB            45
`define CHI5PC_DAT_FLIT_DATAID_LSB            44
`define CHI5PC_DAT_FLIT_DATAID_RANGE          45:44

//`define CHI5PC_DAT_FLIT_DAT_RSVDC_WIDTH          4
`define CHI5PC_DAT_FLIT_RSVDC_MSB            46+DAT_RSVDC_WIDTH
`define CHI5PC_DAT_FLIT_RSVDC_LSB            46
`define CHI5PC_DAT_FLIT_RSVDC_RANGE          `CHI5PC_DAT_FLIT_RSVDC_MSB:`CHI5PC_DAT_FLIT_RSVDC_LSB
// END OF BUS CHI5PC_DAT_FLIT

// START OF BUS CHI5PC_128B_DAT_FLIT
`define CHI5PC_128B_DAT_FLIT_BE_WIDTH          16
`define CHI5PC_128B_DAT_FLIT_BE_MSB            61+DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_BE_LSB            46+DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_BE_RANGE          `CHI5PC_128B_DAT_FLIT_BE_MSB:`CHI5PC_128B_DAT_FLIT_BE_LSB

`define CHI5PC_128B_DAT_FLIT_DATA_WIDTH          128
`define CHI5PC_128B_DAT_FLIT_DATA_MSB            189+DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_DATA_LSB            62+DAT_RSVDC_WIDTH
`define CHI5PC_128B_DAT_FLIT_DATA_RANGE          `CHI5PC_128B_DAT_FLIT_DATA_MSB:`CHI5PC_128B_DAT_FLIT_DATA_LSB
// END OF BUS CHI5PC_128B_DAT_FLIT

// START OF BUS CHI5PC_256B_DAT_FLIT
`define CHI5PC_256B_DAT_FLIT_BE_WIDTH          32
`define CHI5PC_256B_DAT_FLIT_BE_MSB            77+DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_BE_LSB            46+DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_BE_RANGE          `CHI5PC_256B_DAT_FLIT_BE_MSB:`CHI5PC_256B_DAT_FLIT_BE_LSB

`define CHI5PC_256B_DAT_FLIT_DATA_WIDTH          256
`define CHI5PC_256B_DAT_FLIT_DATA_MSB            333+DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_DATA_LSB            78+DAT_RSVDC_WIDTH
`define CHI5PC_256B_DAT_FLIT_DATA_RANGE          `CHI5PC_256B_DAT_FLIT_DATA_MSB:`CHI5PC_256B_DAT_FLIT_DATA_LSB
// END OF BUS CHI5PC_256B_DAT_FLIT

// START OF BUS CHI5PC_512B_DAT_FLIT
`define CHI5PC_512B_DAT_FLIT_BE_WIDTH          64
`define CHI5PC_512B_DAT_FLIT_BE_MSB            109+DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_BE_LSB            46+DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_BE_RANGE          `CHI5PC_512B_DAT_FLIT_BE_MSB:`CHI5PC_512B_DAT_FLIT_BE_LSB

`define CHI5PC_512B_DAT_FLIT_DATA_WIDTH          512
`define CHI5PC_512B_DAT_FLIT_DATA_MSB            621+DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_DATA_LSB            110+DAT_RSVDC_WIDTH
`define CHI5PC_512B_DAT_FLIT_DATA_RANGE          `CHI5PC_512B_DAT_FLIT_DATA_MSB:`CHI5PC_512B_DAT_FLIT_DATA_LSB
// END OF BUS CHI5PC_512B_DAT_FLIT

// START OF VERBATIM

///////////////////////////////////////////////////////////////////////////////
// Chi5 op constants                                                       //
///////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

`define CHI5PC_REQLINKFLIT  5'h00
`define CHI5PC_READSHARED  5'h01
`define CHI5PC_READCLEAN  5'h02
`define CHI5PC_READONCE  5'h03
`define CHI5PC_READNOSNP  5'h04
`define CHI5PC_PCRDRETURN  5'h05
`define CHI5PC_READUNIQUE  5'h07
`define CHI5PC_CLEANSHARED  5'h08
`define CHI5PC_CLEANINVALID  5'h09
`define CHI5PC_MAKEINVALID  5'h0a
`define CHI5PC_CLEANUNIQUE  5'h0b
`define CHI5PC_MAKEUNIQUE  5'h0c
`define CHI5PC_EVICT  5'h0d
`define CHI5PC_EOBARRIER  5'h0e
`define CHI5PC_ECBARRIER  5'h0f
`define CHI5PC_DVMOP  5'h14
`define CHI5PC_WRITEEVICTFULL  5'h15
`define CHI5PC_WRITECLEANPTL  5'h16
`define CHI5PC_WRITECLEANFULL  5'h17
`define CHI5PC_WRITEUNIQUEPTL  5'h18
`define CHI5PC_WRITEUNIQUEFULL  5'h19
`define CHI5PC_WRITEBACKPTL  5'h1a
`define CHI5PC_WRITEBACKFULL  5'h1b
`define CHI5PC_WRITENOSNPPTL  5'h1c
`define CHI5PC_WRITENOSNPFULL  5'h1d
`define CHI5PC_RSPLINKFLIT  4'h0
`define CHI5PC_SNPRESP  4'h1
`define CHI5PC_COMPACK  4'h2
`define CHI5PC_RETRYACK  4'h3
`define CHI5PC_COMP  4'h4
`define CHI5PC_COMPDBIDRESP  4'h5
`define CHI5PC_DBIDRESP  4'h6
`define CHI5PC_PCRDGRANT  4'h7
`define CHI5PC_READRECEIPT  4'h8
`define CHI5PC_SNPLINKFLIT  4'h0
`define CHI5PC_SNPSHARED  4'h1
`define CHI5PC_SNPCLEAN  4'h2
`define CHI5PC_SNPONCE  4'h3
`define CHI5PC_SNPUNIQUE  4'h7
`define CHI5PC_SNPCLEANSHARED  4'h8
`define CHI5PC_SNPCLEANINVALID  4'h9
`define CHI5PC_SNPMAKEINVALID  4'ha
`define CHI5PC_SNPDVMOP  4'hd
`define CHI5PC_DATLINKFLIT  3'h0
`define CHI5PC_SNPRESPDATA  3'h1
`define CHI5PC_COPYBACKWRDATA  3'h2
`define CHI5PC_NONCOPYBACKWRDATA  3'h3
`define CHI5PC_COMPDATA  3'h4
`define CHI5PC_SNPRESPDATAPTL  3'h5
// START OF VERBATIM

///////////////////////////////////////////////////////////////////////////////
// Chi5 size constants                                                     //
///////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

`define CHI5PC_SIZE1B  3'h0
`define CHI5PC_SIZE2B  3'h1
`define CHI5PC_SIZE4B  3'h2
`define CHI5PC_SIZE8B  3'h3
`define CHI5PC_SIZE16B  3'h4
`define CHI5PC_SIZE32B  3'h5
`define CHI5PC_SIZE64B  3'h6
// START OF VERBATIM

///////////////////////////////////////////////////////////////////////////////
// It's not possible to derive the bit range of the snoop flit's Addr field  //
// just from the constants above, so here it is called out explicitly.       //
///////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

// SIGNAL CHI5PC_SNP_EFF_ADDR
`define CHI5PC_SNP_EFF_ADDR_WIDTH          41
`define CHI5PC_SNP_EFF_ADDR_MSB            43
`define CHI5PC_SNP_EFF_ADDR_LSB            3
`define CHI5PC_SNP_EFF_ADDR_RANGE          43:3

// START OF VERBATIM

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Chi5 DVM address/data field constants                                                                  //
//                                                                                                          //
// These constants provide the bit positions in the respective flit fields.                                 //
// For example, to get the VMID out of a DVM request, you would do:                                         //
//                                                                                                          //
//   assign flit_addr[`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] = RXREQFLIT[`CHI5PC_REQ_FLIT_ADDR_RANGE];                  //
//   assign dvm_vmid[`CHI5PC_REQ_FLIT_ADDR_DVM_VMID_WIDTH-1:0] = flit_addr[`CHI5PC_REQ_FLIT_ADDR_DVM_VMID_RANGE]; //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

// START OF BUS CHI5PC_REQ_FLIT_ADDR_DVM
`define CHI5PC_REQ_FLIT_ADDR_DVM_PARTNUM_WIDTH          1
`define CHI5PC_REQ_FLIT_ADDR_DVM_PARTNUM_MSB            3
`define CHI5PC_REQ_FLIT_ADDR_DVM_PARTNUM_LSB            3
`define CHI5PC_REQ_FLIT_ADDR_DVM_PARTNUM_RANGE          3

`define CHI5PC_REQ_FLIT_ADDR_DVM_VAVALID_WIDTH          1
`define CHI5PC_REQ_FLIT_ADDR_DVM_VAVALID_MSB            4
`define CHI5PC_REQ_FLIT_ADDR_DVM_VAVALID_LSB            4
`define CHI5PC_REQ_FLIT_ADDR_DVM_VAVALID_RANGE          4

`define CHI5PC_REQ_FLIT_ADDR_DVM_VMIDVALID_WIDTH          1
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMIDVALID_MSB            5
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMIDVALID_LSB            5
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMIDVALID_RANGE          5

`define CHI5PC_REQ_FLIT_ADDR_DVM_ASIDVALID_WIDTH          1
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASIDVALID_MSB            6
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASIDVALID_LSB            6
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASIDVALID_RANGE          6

`define CHI5PC_REQ_FLIT_ADDR_DVM_SECURE_WIDTH          2
`define CHI5PC_REQ_FLIT_ADDR_DVM_SECURE_MSB            8
`define CHI5PC_REQ_FLIT_ADDR_DVM_SECURE_LSB            7
`define CHI5PC_REQ_FLIT_ADDR_DVM_SECURE_RANGE          8:7

`define CHI5PC_REQ_FLIT_ADDR_DVM_HYP_WIDTH          2
`define CHI5PC_REQ_FLIT_ADDR_DVM_HYP_MSB            10
`define CHI5PC_REQ_FLIT_ADDR_DVM_HYP_LSB            9
`define CHI5PC_REQ_FLIT_ADDR_DVM_HYP_RANGE          10:9

`define CHI5PC_REQ_FLIT_ADDR_DVM_TYPE_WIDTH          3
`define CHI5PC_REQ_FLIT_ADDR_DVM_TYPE_MSB            13
`define CHI5PC_REQ_FLIT_ADDR_DVM_TYPE_LSB            11
`define CHI5PC_REQ_FLIT_ADDR_DVM_TYPE_RANGE          13:11

`define CHI5PC_REQ_FLIT_ADDR_DVM_VMID_WIDTH          8
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMID_MSB            21
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMID_LSB            14
`define CHI5PC_REQ_FLIT_ADDR_DVM_VMID_RANGE          21:14

`define CHI5PC_REQ_FLIT_ADDR_DVM_ASID_WIDTH          16
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASID_MSB            37
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASID_LSB            22
`define CHI5PC_REQ_FLIT_ADDR_DVM_ASID_RANGE          37:22

`define CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_WIDTH          2
`define CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_MSB            39
`define CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_LSB            38
`define CHI5PC_REQ_FLIT_ADDR_DVM_S2S1_RANGE          39:38

`define CHI5PC_REQ_FLIT_ADDR_DVM_L_WIDTH          1
`define CHI5PC_REQ_FLIT_ADDR_DVM_L_MSB            40
`define CHI5PC_REQ_FLIT_ADDR_DVM_L_LSB            40
`define CHI5PC_REQ_FLIT_ADDR_DVM_L_RANGE          40
// END OF BUS CHI5PC_REQ_FLIT_ADDR_DVM

// START OF BUS CHI5PC_DAT_FLIT_DATA_DVM
`define CHI5PC_DAT_FLIT_DATA_DVM_ADDR_WIDTH          43
`define CHI5PC_DAT_FLIT_DATA_DVM_ADDR_MSB            46
`define CHI5PC_DAT_FLIT_DATA_DVM_ADDR_LSB            4
`define CHI5PC_DAT_FLIT_DATA_DVM_ADDR_RANGE          46:4
// END OF BUS CHI5PC_DAT_FLIT_DATA_DVM

// START OF BUS CHI5PC_SNP_FLIT_ADDR_DVM
`define CHI5PC_SNP_FLIT_ADDR_DVM_PARTNUM_WIDTH          1
`define CHI5PC_SNP_FLIT_ADDR_DVM_PARTNUM_MSB            3
`define CHI5PC_SNP_FLIT_ADDR_DVM_PARTNUM_LSB            3
`define CHI5PC_SNP_FLIT_ADDR_DVM_PARTNUM_RANGE          3

`define CHI5PC_SNP_FLIT_ADDR_DVM_VAVALID_WIDTH          1
`define CHI5PC_SNP_FLIT_ADDR_DVM_VAVALID_MSB            4
`define CHI5PC_SNP_FLIT_ADDR_DVM_VAVALID_LSB            4
`define CHI5PC_SNP_FLIT_ADDR_DVM_VAVALID_RANGE          4

`define CHI5PC_SNP_FLIT_ADDR_DVM_VMIDVALID_WIDTH          1
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMIDVALID_MSB            5
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMIDVALID_LSB            5
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMIDVALID_RANGE          5

`define CHI5PC_SNP_FLIT_ADDR_DVM_ASIDVALID_WIDTH          1
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASIDVALID_MSB            6
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASIDVALID_LSB            6
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASIDVALID_RANGE          6

`define CHI5PC_SNP_FLIT_ADDR_DVM_SECURE_WIDTH          2
`define CHI5PC_SNP_FLIT_ADDR_DVM_SECURE_MSB            8
`define CHI5PC_SNP_FLIT_ADDR_DVM_SECURE_LSB            7
`define CHI5PC_SNP_FLIT_ADDR_DVM_SECURE_RANGE          8:7

`define CHI5PC_SNP_FLIT_ADDR_DVM_HYP_WIDTH          2
`define CHI5PC_SNP_FLIT_ADDR_DVM_HYP_MSB            10
`define CHI5PC_SNP_FLIT_ADDR_DVM_HYP_LSB            9
`define CHI5PC_SNP_FLIT_ADDR_DVM_HYP_RANGE          10:9

`define CHI5PC_SNP_FLIT_ADDR_DVM_TYPE_WIDTH          3
`define CHI5PC_SNP_FLIT_ADDR_DVM_TYPE_MSB            13
`define CHI5PC_SNP_FLIT_ADDR_DVM_TYPE_LSB            11
`define CHI5PC_SNP_FLIT_ADDR_DVM_TYPE_RANGE          13:11

`define CHI5PC_SNP_FLIT_ADDR_DVM_VMID_WIDTH          8
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMID_MSB            21
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMID_LSB            14
`define CHI5PC_SNP_FLIT_ADDR_DVM_VMID_RANGE          21:14

`define CHI5PC_SNP_FLIT_ADDR_DVM_ASID_WIDTH          16
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASID_MSB            37
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASID_LSB            22
`define CHI5PC_SNP_FLIT_ADDR_DVM_ASID_RANGE          37:22

`define CHI5PC_SNP_FLIT_ADDR_DVM_S2S1_WIDTH          2
`define CHI5PC_SNP_FLIT_ADDR_DVM_S2S1_MSB            39
`define CHI5PC_SNP_FLIT_ADDR_DVM_S2S1_LSB            38
`define CHI5PC_SNP_FLIT_ADDR_DVM_S2S1_RANGE          39:38

`define CHI5PC_SNP_FLIT_ADDR_DVM_L_WIDTH          1
`define CHI5PC_SNP_FLIT_ADDR_DVM_L_MSB            40
`define CHI5PC_SNP_FLIT_ADDR_DVM_L_LSB            40
`define CHI5PC_SNP_FLIT_ADDR_DVM_L_RANGE          40

`define CHI5PC_SNP_FLIT_ADDR_DVM_PART1ADDR_WIDTH          3
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART1ADDR_MSB            43
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART1ADDR_LSB            41
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART1ADDR_RANGE          43:41

`define CHI5PC_SNP_FLIT_ADDR_DVM_PART2ADDR_WIDTH          40
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART2ADDR_MSB            43
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART2ADDR_LSB            4
`define CHI5PC_SNP_FLIT_ADDR_DVM_PART2ADDR_RANGE          43:4
// END OF BUS CHI5PC_SNP_FLIT_ADDR_DVM

// START OF VERBATIM

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Chi5 MemAttr/SnpAttr field constants                                                          //
//                                                                                                 //
// These constants provide the bit positions in the respective flit fields.                        //
// For example, to get the Cacheable bit out of a request, you would do:                           //
//                                                                                                 //
//   assign mem_attr[`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] = RXREQFLIT[`CHI5PC_REQ_FLIT_MEMATTR_RANGE];    //
//   assign cacheable[`CHI5PC_MEMATTR_CACHEABLE_WIDTH-1:0] = mem_attr[`CHI5PC_MEMATTR_CACHEABLE_RANGE];  //
//                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

// START OF BUS CHI5PC_MEMATTR
`define CHI5PC_MEMATTR_EARLYWRACK_WIDTH          1
`define CHI5PC_MEMATTR_EARLYWRACK_MSB            0
`define CHI5PC_MEMATTR_EARLYWRACK_LSB            0
`define CHI5PC_MEMATTR_EARLYWRACK_RANGE          0

`define CHI5PC_MEMATTR_DEVICE_WIDTH          1
`define CHI5PC_MEMATTR_DEVICE_MSB            1
`define CHI5PC_MEMATTR_DEVICE_LSB            1
`define CHI5PC_MEMATTR_DEVICE_RANGE          1

`define CHI5PC_MEMATTR_CACHEABLE_WIDTH          1
`define CHI5PC_MEMATTR_CACHEABLE_MSB            2
`define CHI5PC_MEMATTR_CACHEABLE_LSB            2
`define CHI5PC_MEMATTR_CACHEABLE_RANGE          2

`define CHI5PC_MEMATTR_ALLOCATE_WIDTH          1
`define CHI5PC_MEMATTR_ALLOCATE_MSB            3
`define CHI5PC_MEMATTR_ALLOCATE_LSB            3
`define CHI5PC_MEMATTR_ALLOCATE_RANGE          3
// END OF BUS CHI5PC_MEMATTR

// START OF BUS CHI5PC_SNPATTR
`define CHI5PC_SNPATTR_SNOOPABLE_WIDTH          1
`define CHI5PC_SNPATTR_SNOOPABLE_MSB            0
`define CHI5PC_SNPATTR_SNOOPABLE_LSB            0
`define CHI5PC_SNPATTR_SNOOPABLE_RANGE          0

`define CHI5PC_SNPATTR_SNPDOMAIN_WIDTH          1
`define CHI5PC_SNPATTR_SNPDOMAIN_MSB            1
`define CHI5PC_SNPATTR_SNPDOMAIN_LSB            1
`define CHI5PC_SNPATTR_SNPDOMAIN_RANGE          1
// END OF BUS CHI5PC_SNPATTR

// START OF VERBATIM

///////////////////////////////////////////////////////////////////////////////
// LINKACTIVE State Constants (encoded as {LA_REQ, LA_ACK})                  //
///////////////////////////////////////////////////////////////////////////////
// END OF VERBATIM

`define CHI5PC_TXLA_STOP  2'b00
`define CHI5PC_TXLA_ACTIVATE  2'b10
`define CHI5PC_TXLA_RUN  2'b11
`define CHI5PC_TXLA_DEACTIVATE  2'b01
`define CHI5PC_RXLA_STOP  2'b00
`define CHI5PC_RXLA_ACTIVATE  2'b10
`define CHI5PC_RXLA_RUN  2'b11
`define CHI5PC_RXLA_DEACTIVATE  2'b01
`endif // CHI5PC_DEFINES_V
