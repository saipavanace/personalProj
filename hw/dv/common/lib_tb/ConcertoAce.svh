////////////////////////////////////////////////////////////////////////////////
// ACE State
////////////////////////////////////////////////////////////////////////////////
typedef enum bit [2:0] {

  ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD

} aceState_t;

typedef bit [($size(aceState_t)*SYS_nSysAIUs)-1:0] aceStatesInBits_t;

static aceState_t aceState_List[] =
  '{
    ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD
  };

static function void convertAceStatesToBits (aceState_t states [SYS_nSysAIUs], output aceStatesInBits_t result);
  for (int c = 0; c < SYS_nSysAIUs; c++) begin
    result[ (c*$size(aceState_t)) +: $size(aceState_t) ] = states[c];
  end
endfunction : convertAceStatesToBits

static function void convertAceBitsToStates (aceStatesInBits_t value, output aceState_t states [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs]);
  for (int c = 0; c < SYS_nSysAIUs; c++) begin
    states[c] = aceState_t'(value[ (c*$size(aceState_t)) +: $size(aceState_t) ]);
  end
endfunction : convertAceBitsToStates

//
// Check if the cacheline states of AIUs is legal
//
static function bit isLegalAceCacheStates (aceState_t states [SYS_nSysAIUs] );
    aceState_t i_state;
    aceState_t j_state;
    for (int i = 0; i < SYS_nSysAIUs; i++) begin
      i_state = states[i]; // reference state
      for (int j = i+1; j < SYS_nSysAIUs; j++) begin
        j_state = states[j]; // others state
        case (i_state)
          ACE_UD, ACE_UC :
            begin
              if (!(j_state inside { ACE_IX })) return 0;
            end
          ACE_SD     :
            begin
              if (!(j_state inside { ACE_IX, ACE_SC })) return 0;
            end
          ACE_SC :
            begin
              if (!(j_state inside { ACE_IX, ACE_SC, ACE_SD })) return 0;
            end
          ACE_IX :
            begin
              if (!(j_state inside { ACE_IX, ACE_SC, ACE_SD, ACE_UC, ACE_UD })) return 0;
            end
        endcase
      end
    end
    return 1;
endfunction : isLegalAceCacheStates

//
// generate legal ACE cache state vector
//
static function void genLegalAceStates (output aceState_t statesList [$] [SYS_nSysAIUs]);

  aceState_t  states [SYS_nSysAIUs];
  int         count  [SYS_nSysAIUs];
  int         total;

  total = 1;
  for (int i=0; i < SYS_nSysAIUs; i++) begin
    total = total * aceState_List.size;
    count[i] = total;
  end

  for (int i=0; i < total; i++) begin
    for (int c=0; c < SYS_nSysAIUs; c++) begin
      states[c] = aceState_List[(i / (count[c] / aceState_List.size)) % aceState_List.size];
    end
    if (isLegalAceCacheStates (states)) begin
      statesList.push_back(states);
    end
  end

endfunction : genLegalAceStates

////////////////////////////////////////////////////////////////////////////////
// ACE Message Type
////////////////////////////////////////////////////////////////////////////////

typedef bit [3:0] AceRdMsgType_t;
typedef bit [2:0] AceWrMsgType_t;

localparam AceRdMsgType_t ACE_READ_ONCE             = 4'b0000;
localparam AceRdMsgType_t ACE_READ_SHARED           = 4'b0001;
localparam AceRdMsgType_t ACE_READ_CLEAN            = 4'b0010;
localparam AceRdMsgType_t ACE_READ_NOT_SHARED_DIRTY = 4'b0011;
localparam AceRdMsgType_t ACE_READ_UNIQUE           = 4'b0111;
localparam AceRdMsgType_t ACE_CLEAN_UNIQUE          = 4'b1011;
localparam AceRdMsgType_t ACE_MAKE_UNIQUE           = 4'b1100;
localparam AceRdMsgType_t ACE_CLEAN_SHARED          = 4'b1000;
localparam AceRdMsgType_t ACE_CLEAN_INVALID         = 4'b1001;
localparam AceRdMsgType_t ACE_MAKE_INVALID          = 4'b1101;
localparam AceRdMsgType_t ACE_DVM_COMPLETE          = 4'b1110;
localparam AceRdMsgType_t ACE_DVM_MESSAGE           = 4'b1111;

typedef enum AceRdMsgType_t {

  eAceReadOnce            = ACE_READ_ONCE,
  eAceReadShared          = ACE_READ_SHARED,
  eAceReadClean           = ACE_READ_CLEAN,
  eAceReadNotSharedDirty  = ACE_READ_NOT_SHARED_DIRTY,
  eAceReadUnique          = ACE_READ_UNIQUE,
  eAceCleanUnique         = ACE_CLEAN_UNIQUE,
  eAceMakeUnique          = ACE_MAKE_UNIQUE,
  eAceCleanShared         = ACE_CLEAN_SHARED,
  eAceCleanInvalid        = ACE_CLEAN_INVALID,
  eAceMakeInvalid         = ACE_MAKE_INVALID,
  eAceDvmComplete         = ACE_DVM_COMPLETE,
  eAceDvmMessage          = ACE_DVM_MESSAGE

} eMsgACErd;

localparam AceWrMsgType_t ACE_WRITE_UNIQUE          = 3'b000;
localparam AceWrMsgType_t ACE_WRITE_LINE_UNIQUE     = 3'b001;
localparam AceWrMsgType_t ACE_WRITE_CLEAN           = 3'b010;
localparam AceWrMsgType_t ACE_WRITE_BACK            = 3'b011;
localparam AceWrMsgType_t ACE_EVICT                 = 3'b100;
localparam AceWrMsgType_t ACE_WRITE_EVICT           = 3'b101;

typedef enum AceWrMsgType_t {

  eAceWriteUnique         = ACE_WRITE_UNIQUE,
  eAceWriteLineUnique     = ACE_WRITE_LINE_UNIQUE,
  eAceWriteClean          = ACE_WRITE_CLEAN,
  eAceWriteBack           = ACE_WRITE_BACK,
  eAceEvict               = ACE_EVICT,
  eAceWriteEvict          = ACE_WRITE_EVICT

} eMsgACEwr;

////////////////////////////////////////////////////////////////////////////////
// Long version of ACE message type encoding - combining ACE rd and ACE wr
////////////////////////////////////////////////////////////////////////////////

typedef bit [4:0] AceMsgType_t;

localparam AceMsgType_t L_ACE_READ_ONCE             = 5'b00000;
localparam AceMsgType_t L_ACE_READ_SHARED           = 5'b00001;
localparam AceMsgType_t L_ACE_READ_CLEAN            = 5'b00010;
localparam AceMsgType_t L_ACE_READ_NOT_SHARED_DIRTY = 5'b00011;
localparam AceMsgType_t L_ACE_READ_UNIQUE           = 5'b00111;
localparam AceMsgType_t L_ACE_CLEAN_UNIQUE          = 5'b01011;
localparam AceMsgType_t L_ACE_MAKE_UNIQUE           = 5'b01100;
localparam AceMsgType_t L_ACE_CLEAN_SHARED          = 5'b01000;
localparam AceMsgType_t L_ACE_CLEAN_INVALID         = 5'b01001;
localparam AceMsgType_t L_ACE_MAKE_INVALID          = 5'b01101;
localparam AceMsgType_t L_ACE_DVM_COMPLETE          = 5'b01110;
localparam AceMsgType_t L_ACE_DVM_MESSAGE           = 5'b01111;

localparam AceMsgType_t L_ACE_WRITE_UNIQUE          = 5'b10000;
localparam AceMsgType_t L_ACE_WRITE_LINE_UNIQUE     = 5'b10001;
localparam AceMsgType_t L_ACE_WRITE_CLEAN           = 5'b10010;
localparam AceMsgType_t L_ACE_WRITE_BACK            = 5'b10011;
localparam AceMsgType_t L_ACE_EVICT                 = 5'b10100;
localparam AceMsgType_t L_ACE_WRITE_EVICT           = 5'b10101;

typedef enum AceMsgType_t {

  eLAceReadOnce           = L_ACE_READ_ONCE,
  eLAceReadShared         = L_ACE_READ_SHARED,
  eLAceReadClean          = L_ACE_READ_CLEAN,
  eLAceReadNotSharedDirty = L_ACE_READ_NOT_SHARED_DIRTY,
  eLAceReadUnique         = L_ACE_READ_UNIQUE,
  eLAceCleanUnique        = L_ACE_CLEAN_UNIQUE,
  eLAceMakeUnique         = L_ACE_MAKE_UNIQUE,
  eLAceCleanShared        = L_ACE_CLEAN_SHARED,
  eLAceCleanInvalid       = L_ACE_CLEAN_INVALID,
  eLAceMakeInvalid        = L_ACE_MAKE_INVALID,
  eLAceDvmComplete        = L_ACE_DVM_COMPLETE,
  eLAceDvmMessage         = L_ACE_DVM_MESSAGE,

  eLAceWriteUnique        = L_ACE_WRITE_UNIQUE,
  eLAceWriteLineUnique    = L_ACE_WRITE_LINE_UNIQUE,
  eLAceWriteClean         = L_ACE_WRITE_CLEAN,
  eLAceWriteBack          = L_ACE_WRITE_BACK,
  eLAceEvict              = L_ACE_EVICT,
  eLAceWriteEvict         = L_ACE_WRITE_EVICT

} eMsgACE;

////////////////////////////////////////////////////////////////////////////////
// ACE Snoop Result Type
////////////////////////////////////////////////////////////////////////////////

typedef struct packed {

  bit WU;
  bit IS;
  bit PD;
  bit DT;

} aceSnoopResult_t;

// 3.4.2 ReadOnce
// A ReadOnce transaction is processed as a CmdRdCpy protocol transaction where
// the allowed ending cache states are UC, OC, and SC.
//
// 3.4.3 ReadShared
// A ReadShared transaction is processed as a CmdRdVld protocol transaction where
// the allowed ending cache states are UD, UC, OD, OC, and SC.
//
// 3.4.4 ReadClean
// A ReadClean transaction is processed as a CmdRdVld protocol transaction where
// the allowed ending cache states are UC, OC, and SC.
//
// 3.4.5 ReadNotSharedDirty
// A ReadNotSharedDirty transaction is processed as a CmdRdVld protocol transaction where
// the allowed ending cache states are UD, UC, and SC.
//
// 3.4.6. ReadUnique
// A ReadUnique transaction is processed as a CmdRdUnq protocol transaction where
// the allowed ending cache states are UD and UC.
//
// 3.4.7 CleanUnique
// A CleanUnique transaction is processed as a CmdClnUnq protocol transaction where
// the allowed ending cache states are UD and UC.
//
// 3.4.8 MakeUnique
// A MakeUnique transaction is processed as a CmdClnUnq protocol transaction where
// the allowed ending cache states are UD and UC.
//
// 3.4.9 CleanShared
// A CleanShared transaction is processed as a CmdClnVld protocol transaction where
// the allowed ending cache states are UC, OC, SC, and IX.
//
// 3.4.10 CleanInvalid
// A CleanInvalid transaction is processed as a CmdClnInv protocol transaction where
// the allowed ending cache state is IX.
//
// 3.4.11 MakeInvalid
// A MakeInvalid transaction is processed as a CmdClnInv protocol transaction where
// the allowed ending cache state is IX.
//
// 3.4.13 WriteUnique
// A WriteUnique transaction is processed as a CmdWrUnqPtl protocol transaction where
// the allowed ending cache states are SC and IX.
//
// 3.4.14 WriteLineUnique
// A WriteLineUnique transaction is processed as a CmdWrUnqFull protocol transaction where
// the allowed ending cache states are SC and IX.
//
// 3.4.15 WriteClean
// A WriteClean transaction is processed as a CmdUpd protocol transaction where
// the allowed ending cache states are UC and SC.
//
// 3.4.16 WriteBack
// A WriteBack transaction is processed as a CmdUpd protocol transaction where
// the allowed ending cache state is IX.
//
// 3.4.17 Evict
// An Evict transaction is processed as a CmdUpd protocol transaction where
// the allowed ending cache state is IX.
//
// 3.4.18 WriteEvict
// A WriteEvict transaction is processed as a CmdUpd protocol transaction where
// the allowed ending cache state is IX.

//-----------------------------------------------------------------------------------
//         |                      |                | Ending State |
// ARSNOOP | ACE Read Transaction | CMDreq Message | UD UC OD OC  | Notes
//-----------------------------------------------------------------------------------
// 0B0000  | ReadOnce             | CmdRdCpy       | 0  1  0  1   | See Section 3.4.2
// 0B0001  | ReadShared           | CmdRdVld       | 1  1  1  1   | See Section 3.4.3
// 0B0010  | ReadClean            | CmdRdCln       | 0  1  0  1   | See Section 3.4.4
// 0B0011  | ReadNotSharedDirty   | CmdRdVld       | 1  1  0  1   | See Section 3.4.5
// 0B0111  | ReadUnique           | CmdRdUnq       | 1  1  0  0   | See Section 3.4.6
// 0B1011  | CleanUnique          | CmdClnUnq      | 1  1  0  0   | See Section 3.4.7
// 0B1100  | MakeUnique           | CmdClnUnq      | 1  1  0  0   | See Section 3.4.8
// 0B1000  | CleanShared          | CmdClnVld      | 0  1  0  1   | See Section 3.4.9
// 0B1001  | CleanInvalid         | CmdClnInv      | 0  0  0  0   | See Section 3.4.10
// 0B1101  | MakeInvalid          | CmdClnInv      | 0  0  0  0   | See Section 3.4.11
// 0B1110  | DVM Complete         | N/A            | 1  1  1  1   | See Section 3.8.1
// 0B1111  | DVM Message          | CmdDvmMsg      | 1  1  1  1   | See Section 3.8.1
//------------------------------------------------------------------------------------
// Table 3: ACE ARSNOOP to CMDreq Message Mapping
//------------------------------------------------------------------------------------

//
// function mapAceReadsToCMDreq
//
static function bit mapAceReadsToCMDreq (input eMsgACErd ace, output eMsgCMD cmd, output bit isUD, output bit isUC, output bit isOD, output bit isOC);
  bit valid;
  valid = 0;
  case (ace)
    //eAceReadOnce           : begin valid = 1; cmd = eCmdRdCpy;  isUD = 0; isUC = 1; isOD = 0; isOC = 1; end
    eAceReadShared         : begin valid = 1; cmd = eCmdRdVld;  isUD = 1; isUC = 1; isOD = 1; isOC = 1; end
    eAceReadClean          : begin valid = 1; cmd = eCmdRdCln;  isUD = 0; isUC = 1; isOD = 0; isOC = 1; end
    eAceReadNotSharedDirty : begin valid = 1; cmd = eCmdRdCln;  isUD = 1; isUC = 1; isOD = 0; isOC = 1; end
    eAceReadUnique         : begin valid = 1; cmd = eCmdRdUnq;  isUD = 1; isUC = 1; isOD = 0; isOC = 0; end
    eAceCleanUnique        : begin valid = 1; cmd = eCmdClnUnq; isUD = 1; isUC = 1; isOD = 0; isOC = 0; end
    eAceMakeUnique         : begin valid = 1; cmd = eCmdClnUnq; isUD = 1; isUC = 1; isOD = 0; isOC = 0; end
    eAceCleanShared        : begin valid = 1; cmd = eCmdClnVld; isUD = 0; isUC = 1; isOD = 0; isOC = 1; end
    eAceCleanInvalid       : begin valid = 1; cmd = eCmdClnInv; isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
    eAceMakeInvalid        : begin valid = 1; cmd = eCmdClnInv; isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
    eAceDvmComplete        : begin valid = 0;                   isUD = 1; isUC = 1; isOD = 1; isOC = 1; end 
    eAceDvmMessage         : begin valid = 1; cmd = eCmdDvmMsg; isUD = 1; isUC = 1; isOD = 1; isOC = 1; end
  endcase
  return valid;
endfunction : mapAceReadsToCMDreq

//
// function mapCMDreqToAceReads
//
static function bit mapCMDreqToAceReads (input eMsgCMD cmd, output eMsgACErd ace);
  bit valid;
  valid = 0;
  case (cmd)
    //eCmdRdCpy              : begin valid = 1; ace = eAceReadOnce;           end
    eCmdRdVld              : begin valid = 1; ace = eAceReadShared;         end
    eCmdRdCln              : begin valid = 1; ace = eAceReadClean;          end
    eCmdRdVld              : begin valid = 1; ace = eAceReadNotSharedDirty; end
    eCmdRdUnq              : begin valid = 1; ace = eAceReadUnique;         end
    eCmdClnUnq             : begin valid = 1; ace = eAceCleanUnique;        end
    eCmdClnUnq             : begin valid = 1; ace = eAceMakeUnique;         end
    eCmdClnVld             : begin valid = 1; ace = eAceCleanShared;        end
    eCmdClnInv             : begin valid = 1; ace = eAceCleanInvalid;       end
    eCmdClnInv             : begin valid = 1; ace = eAceMakeInvalid;        end
    eCmdDvmMsg             : begin valid = 1; ace = eAceDvmMessage;         end
  endcase
  return valid;
endfunction : mapCMDreqToAceReads

//-------------------------------------------------------------------------------------
//         |                       |                | Ending State |
// AWSNOOP | ACE Write Transaction | CMDreq Message | UD UC OD OC  | Notes
//-------------------------------------------------------------------------------------
// 0B000   | WriteUnique           | CmdWrUnqPtl    | -  -  -  -   | See Section 3.4.13
// 0B001   | WriteLineUnique       | CmdWrUnqFull   | -  -  -  -   | See Section 3.4.14
// 0B010   | WriteClean            | CmdUpdVld      | -  1  -  -   | See Section 3.4.15
// 0B011   | WriteBack             | CmdUpdInv      | -  -  -  -   | See Section 3.4.16
// 0B100   | Evict                 | CmdUpdInv      | -  -  -  -   | See Section 3.4.17
// 0B101   | WriteEvict            | CmdUpdInv      | -  -  -  -   | See Section 3.4.18
//-------------------------------------------------------------------------------------
// Table 8: ACE Write Transaction to CMDreq Message Mapping
//-------------------------------------------------------------------------------------

//
// function mapAceWritesToCMDreq
//
static function bit mapAceWritesToCMDreq (input eMsgACEwr ace, output eMsgCMD cmd, output bit isUD, output bit isUC, output bit isOD, output bit isOC);
  bit valid;
  valid = 0;
  case (ace)
    eAceWriteUnique        : begin valid = 1; cmd = eCmdWrUnqPtl;  isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
    eAceWriteLineUnique    : begin valid = 1; cmd = eCmdWrUnqFull; isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
  //  eAceWriteClean         : begin valid = 1; cmd = eCmdUpdVld;    isUD = 0; isUC = 1; isOD = 0; isOC = 0; end
    eAceWriteBack          : begin valid = 1; cmd = eCmdUpdInv;    isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
    eAceEvict              : begin valid = 1; cmd = eCmdUpdInv;    isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
    eAceWriteEvict         : begin valid = 1; cmd = eCmdUpdInv;    isUD = 0; isUC = 0; isOD = 0; isOC = 0; end
  endcase
  return valid;
endfunction : mapAceWritesToCMDreq

//
// function mapCMDreqToAceWrites
//
static function bit mapCMDreqToAceWrites (input eMsgCMD cmd, output eMsgACEwr ace);
  bit valid;
  valid = 0;
  case (cmd)
    eCmdWrUnqPtl           : begin valid = 1; ace = eAceWriteUnique;     end
    eCmdWrUnqFull          : begin valid = 1; ace = eAceWriteLineUnique; end
  //  eCmdUpdVld             : begin valid = 1; ace = eAceWriteClean;      end
    eCmdUpdInv             : begin valid = 1; ace = eAceWriteBack;       end
    eCmdUpdInv             : begin valid = 1; ace = eAceEvict;           end
    eCmdUpdInv             : begin valid = 1; ace = eAceWriteEvict;      end
  endcase
  return valid;
endfunction : mapCMDreqToAceWrites

//---------------------------------------------------------------------
// SNPreq Message  ACSNOOP  ACE Snoop Transaction  Notes
//---------------------------------------------------------------------
// SnpVldDtr      0B0000   ReadShared
// SnpClnDtr      0B0010   ReadClean
// SnpInvDtr      0B0111   ReadUnique
// SnpClnDtw      0B1000   CleanShared
// SnpInvDtw      0B1001   CleanInvalid
// SnpRecall      0B1001   CleanInvalid
// SnpInv         0B1101   MakeInvalid
// N/A            0B1110   DVM Complete           See Section 3.8.2
// SnpDvmMsg      0B1111   DVM Message            See Section 3.8.2
//----------------------------------------------------------------------
// Table 11: SNPreq Message to Agent Snoop Transaction Mapping
//----------------------------------------------------------------------

//
// function mapSNPreqToAce
//
static function bit mapSNPreqToAce (input eMsgSNP snp, output eMsgACErd ace);
  bit valid;
  valid = 0;
  case (snp)
    eSnpVldDtr     : begin valid = 1; ace = eAceReadShared;   end
    eSnpClnDtr     : begin valid = 1; ace = eAceReadClean;    end
    eSnpInvDtr     : begin valid = 1; ace = eAceReadUnique;   end
    eSnpClnDtw     : begin valid = 1; ace = eAceCleanShared;  end
    eSnpInvDtw     : begin valid = 1; ace = eAceCleanInvalid; end
    eSnpRecall     : begin valid = 1; ace = eAceCleanInvalid; end
    eSnpInv        : begin valid = 1; ace = eAceMakeInvalid;  end
    eSnpDvmMsg     : begin valid = 1; ace = eAceDvmMessage;   end
  endcase
  return valid;
endfunction : mapSNPreqToAce

//------------------------------------------------------------------------------
// WU IS PD DT | RV RS DC DT | Notes
//------------------------------------------------------------------------------
// 0  0  0  0  | 0  0  0  0  | Agent is invalid
// 0  0  0  1  | 0  0  0  1  | Agent is invalid and passing clean data
// 0  0  1  1  | 0  1  1  1  | Agent is invalid and passing dirty data/ownership
// 0  1  0  0  | 1  0  0  0  | Agent is valid
// 0  1  0  1  | 1  0  0  1  | Agent is valid and passing clean data
// 0  1  1  1  | 1  1  1  1  | Agent is valid and passing dirty data/ownership
// 1  0  0  0  | 0  1  0  0  | Agent is invalid and passing ownership
// 1  0  0  1  | 0  1  0  1  | Agent is invalid and passing clean data/ownership
// 1  0  1  1  | 0  1  1  1  | Agent is invalid and passing dirty data/ownership
// 1  1  0  0  | 1  0  0  0  | Agent is valid
// 1  1  0  1  | 1  0  0  1  | Agent is valid and passing clean data
// 1  1  1  1  | 1  1  1  1  | Agent is valid and passing dirty data/ownership
//------------------------------------------------------------------------------
// Table 12: ACE Native Snoop Response to Protocol Snoop Result Mapping
//------------------------------------------------------------------------------
//In effect, the ACE snoop response is transformed into the protocol snoop result in the following manner:
//* RV = IsShared
//* RS = (WasUnique && !IsShared) || PassDirty
//* DC = PassDirty
//* DT = DataTransfer

static function bit mapAceSnoopResult (input aceSnoopResult_t ace, output snoopResult_t snp,input bit isSFISnpVldDTW);
  bit valid;
  valid = 0;
  case ({ace.IS, ace.PD, ace.DT})
    3'b000 : begin snp = 4'b0000; valid = 1; end
    3'b001 : begin snp = 4'b0001; valid = 1; end
    3'b011 : begin snp = 4'b0011; valid = 1; end
    3'b100 : begin 
        if (isSFISnpVldDTW) begin
            snp = 4'b1000; 
        end
        else begin
            snp = 4'b1100; 
        end
        valid = 1; 
    end
    3'b101 : begin snp = 4'b1001; valid = 1; end
    3'b111 : begin 
        if (isSFISnpVldDTW) begin
            snp = 4'b1011;
        end
        else begin 
            snp = 4'b1111; 
        end
        valid = 1; 
    end
endcase
  return valid;
endfunction : mapAceSnoopResult

static function bit mapConcertoSnoopResult (input snoopResult_t snp, output aceSnoopResult_t ace);
  bit valid;
  valid = 0;
  case (snp)
    4'b0000 : begin ace = 4'b0000; valid = 1; end
    4'b0001 : begin ace = 4'b0001; valid = 1; end
    4'b0111 : begin ace = 4'b0011; valid = 1; end
    4'b1000 : begin ace = 4'b0100; valid = 1; end
    4'b1001 : begin ace = 4'b0101; valid = 1; end
    4'b1111 : begin ace = 4'b0111; valid = 1; end
    4'b0100 : begin ace = 4'b1000; valid = 1; end
    4'b0101 : begin ace = 4'b1001; valid = 1; end
    4'b0111 : begin ace = 4'b1011; valid = 1; end
    4'b1000 : begin ace = 4'b1100; valid = 1; end
    4'b1001 : begin ace = 4'b1101; valid = 1; end
    4'b1111 : begin ace = 4'b1111; valid = 1; end
  endcase
  return valid;
endfunction : mapConcertoSnoopResult

localparam bit [3:0] aceLegalSnoopResult_List [] =  // {WU,IS,PD,DT}
  '{
     4'b0000,
     4'b0001,
     4'b0011,
     4'b0100,
     4'b0101,
     4'b0111,
     4'b1000,
     4'b1001,
     4'b1011,
     4'b1100,
     4'b1101,
     4'b1111
  };

//-----------------------------------------------------------------------------------
// Concerto  |        |
// Installed |        |
// State     | IS  PD | Notes
//-----------------------------------------------------------------------------------
// IX        | 0   0  | Equivalent to ACE I state
// SC        | 1   0  | Equivalent to ACE SC state
// OC        | 1   0  | Equivalent to ACE SC state
// OD        | 1   1  | Equivalent to ACE SD state
// UC        | 0   0  | Equivalent to ACE UC state
// UD        | 0   1  | Equivalent to ACE UD state
//-----------------------------------------------------------------------------------
// Table 4: Installed Cache States and ACE Read Responses
//-----------------------------------------------------------------------------------

static function void mapStateToAce (input cacheState_t con, output aceState_t ace, output bit is_IS, output bit is_PD);
  case (con)
    IX : begin ace = ACE_IX; is_IS = 0; is_PD = 0; end
    SC : begin ace = ACE_SC; is_IS = 1; is_PD = 0; end
    OC : begin ace = ACE_SC; is_IS = 1; is_PD = 0; end
    OD : begin ace = ACE_SD; is_IS = 1; is_PD = 1; end
    UC : begin ace = ACE_UC; is_IS = 0; is_PD = 0; end
    UD : begin ace = ACE_UD; is_IS = 0; is_PD = 1; end
  endcase
endfunction : mapStateToAce

////////////////////////////////////////////////////////////////////////////////
// ACE Read Address Channel (AR) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_arid_t          arid;
    <%=obj.BlockId + '_con'%>::axi_axaddr_t        araddr;
    <%=obj.BlockId + '_con'%>::axi_axlen_t         arlen;
    <%=obj.BlockId + '_con'%>::axi_axsize_t        arsize;
    <%=obj.BlockId + '_con'%>::axi_axburst_t       arburst;
    <%=obj.BlockId + '_con'%>::axi_axlock_enum_t   arlock;
    <%=obj.BlockId + '_con'%>::axi_arcache_enum_t  arcache;
    <%=obj.BlockId + '_con'%>::axi_axprot_t        arprot;
    <%=obj.BlockId + '_con'%>::axi_axqos_t         arqos;
    <%=obj.BlockId + '_con'%>::axi_axregion_t      arregion;
    <%=obj.BlockId + '_con'%>::axi_aruser_t        aruser;
    <%=obj.BlockId + '_con'%>::axi_axdomain_enum_t ardomain;
    <%=obj.BlockId + '_con'%>::axi_arsnoop_t       arsnoop;
    <%=obj.BlockId + '_con'%>::axi_axbar_t         arbar;

} ace_read_addr_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Write Address Channel (AW) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_awid_t          awid;
    <%=obj.BlockId + '_con'%>::axi_axaddr_t        awaddr;
    <%=obj.BlockId + '_con'%>::axi_axlen_t         awlen;
    <%=obj.BlockId + '_con'%>::axi_axsize_t        awsize;
    <%=obj.BlockId + '_con'%>::axi_axburst_t       awburst;
    <%=obj.BlockId + '_con'%>::axi_axlock_enum_t   awlock;
    <%=obj.BlockId + '_con'%>::axi_awcache_enum_t  awcache;
    <%=obj.BlockId + '_con'%>::axi_axprot_t        awprot;
    <%=obj.BlockId + '_con'%>::axi_axqos_t         awqos;
    <%=obj.BlockId + '_con'%>::axi_axregion_t      awregion;
    <%=obj.BlockId + '_con'%>::axi_awuser_t        awuser;
    <%=obj.BlockId + '_con'%>::axi_axdomain_enum_t awdomain;
    <%=obj.BlockId + '_con'%>::axi_awsnoop_t       awsnoop;
    <%=obj.BlockId + '_con'%>::axi_axbar_t         awbar;
    bit                      awunique;

} ace_write_addr_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Read Data Channel (R) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_arid_t  rid;
    <%=obj.BlockId + '_con'%>::axi_xdata_t rdata[];
    <%=obj.BlockId + '_con'%>::axi_rresp_t rresp;
    <%=obj.BlockId + '_con'%>::axi_ruser_t ruser;

} ace_read_data_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Write Data Channel (W) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_awid_t  wid;
    <%=obj.BlockId + '_con'%>::axi_xdata_t wdata[];
    <%=obj.BlockId + '_con'%>::axi_xstrb_t wstrb[];
    <%=obj.BlockId + '_con'%>::axi_wuser_t wuser;

} ace_write_data_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Write Response Channel (B) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_awid_t       bid;
    <%=obj.BlockId + '_con'%>::axi_bresp_enum_t bresp;
    <%=obj.BlockId + '_con'%>::axi_buser_t      buser;

} ace_write_resp_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Snoop Address Channel (AC) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_axaddr_t  acaddr;
    <%=obj.BlockId + '_con'%>::axi_acsnoop_t acsnoop;
    <%=obj.BlockId + '_con'%>::axi_axprot_t  acprot;

} ace_snoop_addr_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Snoop Response Channel (CR) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_crresp_t crresp;

} ace_snoop_resp_struct;

////////////////////////////////////////////////////////////////////////////////
// ACE Snoop Data Channel (CD) packet
////////////////////////////////////////////////////////////////////////////////
typedef struct {

    <%=obj.BlockId + '_con'%>::axi_cddata_t cddata[];

} ace_snoop_data_struct;

////////////////////////////////////////////////////////////////////////////////
// generate CMDreq messages given a cache state
////////////////////////////////////////////////////////////////////////////////

static eMsgACE AceCmdList_In_IX [] =
    '{
`ifdef ACE_GRAPH_TEST_BRINGUP
        //eLAceReadOnce,
        //eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique
        //eLAceCleanUnique, eLAceMakeUnique,
        //eLAceCleanShared,
        //eLAceCleanInvalid, eLAceMakeInvalid,
        //eLAceWriteUnique,
        //eLAceWriteLineUnique
`else
        eLAceReadOnce,
        eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique,
        eLAceCleanUnique, eLAceMakeUnique,
        eLAceCleanShared,
        eLAceCleanInvalid, eLAceMakeInvalid,
        eLAceWriteUnique,
        eLAceWriteLineUnique
`endif
     };

static eMsgACE AceCmdList_In_SC [] =
    '{
`ifdef ACE_GRAPH_TEST_BRINGUP
        //eLAceReadOnce,
        //eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique
        //eLAceCleanUnique, eLAceMakeUnique,
        //eLAceCleanShared,
        //eLAceWriteUnique,
        //eLAceWriteLineUnique,
        //eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`else
        eLAceReadOnce,
        eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique,
        eLAceCleanUnique, eLAceMakeUnique,
        eLAceCleanShared,
        eLAceWriteUnique,
        eLAceWriteLineUnique,
        eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`endif
     };

static eMsgACE AceCmdList_In_SD [] =
    '{
`ifdef ACE_GRAPH_TEST_BRINGUP
        //eLAceReadOnce,
        //eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique
        //eLAceCleanUnique, eLAceMakeUnique,
        //eLAceWriteClean,
        //eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`else
        eLAceReadOnce,
        eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique,
        eLAceCleanUnique, eLAceMakeUnique,
        eLAceWriteClean,
        eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`endif
     };

static eMsgACE AceCmdList_In_UC [] =
    '{
`ifdef ACE_GRAPH_TEST_BRINGUP
        //eLAceReadOnce,
        //eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique
        //eLAceCleanUnique, eLAceMakeUnique,
        //eLAceCleanShared,
        //eLAceWriteUnique,
        //eLAceWriteLineUnique,
        //eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`else
        eLAceReadOnce,
        eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique,
        eLAceCleanUnique, eLAceMakeUnique,
        eLAceCleanShared,
        eLAceWriteUnique,
        eLAceWriteLineUnique,
        eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`endif
     };

static eMsgACE AceCmdList_In_UD [] =
    '{
`ifdef ACE_GRAPH_TEST_BRINGUP
        //eLAceReadOnce,
        //eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique
        //eLAceCleanUnique, eLAceMakeUnique,
        //eLAceWriteClean,
        //eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`else
        eLAceReadOnce,
        eLAceReadClean,
        eLAceReadNotSharedDirty, eLAceReadShared,
        eLAceReadUnique,
        eLAceCleanUnique, eLAceMakeUnique,
        eLAceWriteClean,
        eLAceWriteBack, eLAceEvict, eLAceWriteEvict
`endif
     };

static function void genAceCMDreqs (aceState_t state, output eMsgACE msg[]);
  case (state)
    ACE_IX : msg = AceCmdList_In_IX;
    ACE_SC : msg = AceCmdList_In_SC;
    ACE_SD : msg = AceCmdList_In_SD;
    ACE_UC : msg = AceCmdList_In_UC;
    ACE_UD : msg = AceCmdList_In_UD;
  endcase
endfunction : genAceCMDreqs

static function bit mapAceOwnerSNPreq (input eMsgACE cmd, output eMsgACE snp);
  bit valid;
  valid = 0;
  case (cmd)
    eLAceReadOnce           : begin valid = 1; snp = eLAceReadOnce;           end
    eLAceReadShared         : begin valid = 1; snp = eLAceReadShared;         end
    eLAceReadClean          : begin valid = 1; snp = eLAceReadClean;          end
    eLAceReadNotSharedDirty : begin valid = 1; snp = eLAceReadNotSharedDirty; end
    eLAceReadUnique         : begin valid = 1; snp = eLAceReadUnique;         end
    eLAceCleanUnique        : begin valid = 1; snp = eLAceCleanInvalid;       end
    eLAceMakeUnique         : begin valid = 1; snp = eLAceMakeInvalid;        end
    eLAceCleanShared        : begin valid = 1; snp = eLAceCleanShared;        end
    eLAceCleanInvalid       : begin valid = 1; snp = eLAceCleanInvalid;       end
    eLAceMakeInvalid        : begin valid = 1; snp = eLAceMakeInvalid;        end

    eLAceWriteUnique        : begin valid = 1; snp = eLAceCleanInvalid;       end
    eLAceWriteLineUnique    : begin valid = 1; snp = eLAceMakeInvalid;        end
  endcase
  return valid;
endfunction : mapAceOwnerSNPreq

////////////////////////////////////////////////////////////////////////////////
// isLegalAceCommandStateTransaction
////////////////////////////////////////////////////////////////////////////////

static function bit isLegalAceCommandStateTransition (
    input  eMsgACE      msg,
    input  bit          IS,
    input  bit          PD,
    input  aceState_t   startingState,
    input  aceState_t   endingState
);
    bit       legal;
    bit       isReadOnce;
    bit       isReadClean;
    bit       isReadNotSharedDirty;
    bit       isReadShared;
    bit       isReadUnique;
    bit       isCleanUnique;
    bit       isMakeUnique;
    bit       isCleanShared;
    bit       isCleanInvalid;
    bit       isMakeInvalid;
    bit       isWriteUnique;
    bit       isWriteLineUnique;
    bit       isWriteClean;
    bit       isWriteBack;
    bit       isEvict;
    bit       isWriteEvict;
    bit       ssIX;
    bit       ssSC;
    bit       ssSD;
    bit       ssUC;
    bit       ssUD;
    bit       esIX;
    bit       esSC;
    bit       esSD;
    bit       esUC;
    bit       esUD;

    legal = 0;

    isReadOnce           = (msg == eLAceReadOnce)           ? 1 : 0;
    isReadClean          = (msg == eLAceReadClean)          ? 1 : 0;
    isReadNotSharedDirty = (msg == eLAceReadNotSharedDirty) ? 1 : 0;
    isReadShared         = (msg == eLAceReadShared)         ? 1 : 0;
    isReadUnique         = (msg == eLAceReadUnique)         ? 1 : 0;
    isCleanUnique        = (msg == eLAceCleanUnique)        ? 1 : 0;
    isMakeUnique         = (msg == eLAceMakeUnique)         ? 1 : 0;
    isCleanShared        = (msg == eLAceCleanShared)        ? 1 : 0;
    isCleanInvalid       = (msg == eLAceCleanInvalid)       ? 1 : 0;
    isMakeInvalid        = (msg == eLAceMakeInvalid)        ? 1 : 0;
    isWriteUnique        = (msg == eLAceWriteUnique)        ? 1 : 0;
    isWriteLineUnique    = (msg == eLAceWriteLineUnique)    ? 1 : 0;
    isWriteClean         = (msg == eLAceWriteClean)         ? 1 : 0;
    isWriteBack          = (msg == eLAceWriteBack)          ? 1 : 0;
    isEvict              = (msg == eLAceEvict)              ? 1 : 0;
    isWriteEvict         = (msg == eLAceWriteEvict)         ? 1 : 0;

    ssIX  = (startingState == ACE_IX) ? 1 : 0;
    ssSC  = (startingState == ACE_SC) ? 1 : 0;
    ssSD  = (startingState == ACE_SD) ? 1 : 0;
    ssUC  = (startingState == ACE_UC) ? 1 : 0;
    ssUD  = (startingState == ACE_UD) ? 1 : 0;

    esIX  = (endingState == ACE_IX) ? 1 : 0;
    esSC  = (endingState == ACE_SC) ? 1 : 0;
    esSD  = (endingState == ACE_SD) ? 1 : 0;
    esUC  = (endingState == ACE_UC) ? 1 : 0;
    esUD  = (endingState == ACE_UD) ? 1 : 0;

    if (ssIX & esIX & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadOnce           &  IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadClean          &  IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadNotSharedDirty &  IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadShared         &  IS & ~PD) legal = 1;
    if (ssIX & esIX & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isCleanShared        & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isCleanShared        &  IS & ~PD) legal = 1;
    if (ssIX & esIX & isCleanInvalid       & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isMakeInvalid        & ~IS & ~PD) legal = 1;
    if (ssIX & esIX & isWriteUnique                   ) legal = 1;
    if (ssIX & esIX & isWriteLineUnique               ) legal = 1;

    if (ssIX & esSC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadClean          &  IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadNotSharedDirty &  IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadShared         &  IS & ~PD) legal = 1;
    if (ssIX & esSC & isReadUnique         & ~IS & ~PD) legal = 1;

    if (ssIX & esSD & isReadNotSharedDirty & ~IS &  PD) legal = 1;
    if (ssIX & esSD & isReadShared         & ~IS &  PD) legal = 1;
    if (ssIX & esSD & isReadShared         &  IS &  PD) legal = 1;
    if (ssIX & esSD & isReadUnique         & ~IS &  PD) legal = 1;
    if (ssIX & esSD & isMakeUnique         & ~IS &  PD) legal = 1;

    if (ssIX & esUC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssIX & esUC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssIX & esUC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssIX & esUC & isReadUnique         & ~IS & ~PD) legal = 1;

    if (ssIX & esUD & isReadNotSharedDirty & ~IS &  PD) legal = 1;
    if (ssIX & esUD & isReadShared         & ~IS &  PD) legal = 1;
    if (ssIX & esUD & isReadUnique         & ~IS &  PD) legal = 1;
    if (ssIX & esUD & isMakeUnique         & ~IS &  PD) legal = 1;

    if (ssSC & esIX & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadOnce           &  IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadClean          &  IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadNotSharedDirty &  IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadShared         &  IS & ~PD) legal = 1;
    if (ssSC & esIX & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isCleanShared        & ~IS & ~PD) legal = 1;
    if (ssSC & esIX & isCleanShared        &  IS & ~PD) legal = 1;
    if (ssSC & esIX & isWriteUnique                   ) legal = 1;
    if (ssSC & esIX & isWriteLineUnique               ) legal = 1;
    if (ssSC & esIX & isEvict                         ) legal = 1;

    if (ssSC & esSC & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadOnce           &  IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadClean          &  IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadNotSharedDirty &  IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadShared         &  IS & ~PD) legal = 1;
    if (ssSC & esSC & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isCleanShared        & ~IS & ~PD) legal = 1;
    if (ssSC & esSC & isCleanShared        &  IS & ~PD) legal = 1;
    if (ssSC & esSC & isWriteUnique                   ) legal = 1;
    if (ssSC & esSC & isWriteLineUnique               ) legal = 1;

    if (ssSC & esSD & isReadNotSharedDirty & ~IS &  PD) legal = 1;
    if (ssSC & esSD & isReadShared         & ~IS &  PD) legal = 1;
    if (ssSC & esSD & isReadShared         &  IS &  PD) legal = 1;
    if (ssSC & esSD & isReadUnique         & ~IS &  PD) legal = 1;
    if (ssSC & esSD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssSC & esUC & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssSC & esUC & isCleanShared        & ~IS & ~PD) legal = 1;

    if (ssSC & esUD & isReadNotSharedDirty & ~IS &  PD) legal = 1;
    if (ssSC & esUD & isReadShared         & ~IS &  PD) legal = 1;
    if (ssSC & esUD & isReadUnique         & ~IS &  PD) legal = 1;
    if (ssSC & esUD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssSD & esIX & isWriteClean                    ) legal = 1;
    if (ssSD & esIX & isWriteBack                     ) legal = 1;

    if (ssSD & esSC & isWriteClean                    ) legal = 1;
    if (ssSD & esSC & isWriteBack                     ) legal = 1;

    if (ssSD & esSD & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadOnce           &  IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadClean          &  IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadNotSharedDirty &  IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadShared         &  IS & ~PD) legal = 1;
    if (ssSD & esSD & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssSD & esSD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssSD & esUD & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssSD & esUD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssUC & esIX & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isCleanShared        & ~IS & ~PD) legal = 1;
    if (ssUC & esIX & isWriteUnique                   ) legal = 1;
    if (ssUC & esIX & isWriteLineUnique               ) legal = 1;
    if (ssUC & esIX & isEvict                         ) legal = 1;
    if (ssUC & esIX & isWriteEvict                    ) legal = 1;

    if (ssUC & esSC & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isCleanShared        & ~IS & ~PD) legal = 1;
    if (ssUC & esSC & isWriteUnique                   ) legal = 1;
    if (ssUC & esSC & isWriteLineUnique               ) legal = 1;

    if (ssUC & esSD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssUC & esUC & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssUC & esUC & isCleanShared        & ~IS & ~PD) legal = 1;

    if (ssUC & esUD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssUD & esIX & isWriteClean                    ) legal = 1;
    if (ssUD & esIX & isWriteBack                     ) legal = 1;

    if (ssUD & esSC & isWriteClean                    ) legal = 1;
    if (ssUD & esSC & isWriteBack                     ) legal = 1;

    if (ssUD & esSD & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssUD & esSD & isMakeUnique         & ~IS & ~PD) legal = 1;

    if (ssUD & esUC & isWriteClean                    ) legal = 1;
    if (ssUD & esUC & isWriteBack                     ) legal = 1;

    if (ssUD & esUD & isReadOnce           & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isReadClean          & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isReadNotSharedDirty & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isReadShared         & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isReadUnique         & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isCleanUnique        & ~IS & ~PD) legal = 1;
    if (ssUD & esUD & isMakeUnique         & ~IS & ~PD) legal = 1;

    return legal;

endfunction : isLegalAceCommandStateTransition 

////////////////////////////////////////////////////////////////////////////////
// isLegalAceSnoopStateTransaction
////////////////////////////////////////////////////////////////////////////////

static function bit isLegalAceSnoopStateTransition (
    input  eMsgACE      msg,
    input  bit          IS,
    input  bit          PD,
    input  bit          DT,
    input  aceState_t   startingState,
    input  aceState_t   endingState
);
    bit       legal;
    bit       isReadOnce;
    bit       isReadClean;
    bit       isReadNotSharedDirty;
    bit       isReadShared;
    bit       isReadUnique;
    bit       isCleanInvalid;
    bit       isMakeInvalid;
    bit       isCleanShared;
    bit       ssIX;
    bit       ssSC;
    bit       ssSD;
    bit       ssUC;
    bit       ssUD;
    bit       esIX;
    bit       esSC;
    bit       esSD;
    bit       esUC;
    bit       esUD;

    legal = 0;

    isReadOnce           = (msg == eLAceReadOnce)           ? 1 : 0;
    isReadClean          = (msg == eLAceReadClean)          ? 1 : 0;
    isReadNotSharedDirty = (msg == eLAceReadNotSharedDirty) ? 1 : 0;
    isReadShared         = (msg == eLAceReadShared)         ? 1 : 0;
    isReadUnique         = (msg == eLAceReadUnique)         ? 1 : 0;
    isCleanInvalid       = (msg == eLAceCleanInvalid)       ? 1 : 0;
    isMakeInvalid        = (msg == eLAceMakeInvalid)        ? 1 : 0;
    isCleanShared        = (msg == eLAceCleanShared)        ? 1 : 0;

    ssIX  = (startingState == ACE_IX) ? 1 : 0;
    ssSC  = (startingState == ACE_SC) ? 1 : 0;
    ssSD  = (startingState == ACE_SD) ? 1 : 0;
    ssUC  = (startingState == ACE_UC) ? 1 : 0;
    ssUD  = (startingState == ACE_UD) ? 1 : 0;

    esIX  = (endingState == ACE_IX) ? 1 : 0;
    esSC  = (endingState == ACE_SC) ? 1 : 0;
    esSD  = (endingState == ACE_SD) ? 1 : 0;
    esUC  = (endingState == ACE_UC) ? 1 : 0;
    esUD  = (endingState == ACE_UD) ? 1 : 0;

    if (ssIX & esIX & isReadOnce           & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isReadClean          & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isReadNotSharedDirty & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isReadShared         & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isReadUnique         & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isCleanInvalid       & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isMakeInvalid        & ~IS & ~PD & ~DT) legal = 1;
    if (ssIX & esIX & isCleanShared        & ~IS & ~PD & ~DT) legal = 1;

    if (ssSC & esIX & isReadOnce           & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isReadClean          & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isReadNotSharedDirty & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isReadShared         & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isReadUnique         & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isCleanInvalid       & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isMakeInvalid        & ~IS & ~PD      ) legal = 1;
    if (ssSC & esIX & isCleanShared        & ~IS & ~PD      ) legal = 1;

    if (ssSC & esSC & isReadOnce           &  IS & ~PD      ) legal = 1;
    if (ssSC & esSC & isReadClean          &  IS & ~PD      ) legal = 1;
    if (ssSC & esSC & isReadNotSharedDirty &  IS & ~PD      ) legal = 1;
    if (ssSC & esSC & isReadShared         &  IS & ~PD      ) legal = 1;
    if (ssSC & esSC & isCleanShared        &  IS & ~PD      ) legal = 1;

    if (ssSD & esIX & isReadOnce           & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isReadClean          & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isReadNotSharedDirty & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isReadShared         & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isReadUnique         & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isCleanInvalid       & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isMakeInvalid        & ~IS & ~PD & ~DT) legal = 1;
    if (ssSD & esIX & isMakeInvalid        & ~IS &  PD &  DT) legal = 1;
    if (ssSD & esIX & isCleanShared        & ~IS &  PD &  DT) legal = 1;

    if (ssSD & esSC & isReadOnce           &  IS &  PD &  DT) legal = 1;
    if (ssSD & esSC & isReadClean          &  IS &  PD &  DT) legal = 1;
    if (ssSD & esSC & isReadNotSharedDirty &  IS &  PD &  DT) legal = 1;
    if (ssSD & esSC & isReadShared         &  IS &  PD &  DT) legal = 1;
    if (ssSD & esSC & isCleanShared        &  IS &  PD &  DT) legal = 1;

    if (ssSD & esSD & isReadOnce           &  IS & ~PD &  DT) legal = 1;
    if (ssSD & esSD & isReadClean          &  IS & ~PD &  DT) legal = 1;
    if (ssSD & esSD & isReadNotSharedDirty &  IS & ~PD &  DT) legal = 1;
    if (ssSD & esSD & isReadShared         &  IS & ~PD &  DT) legal = 1;

    if (ssUC & esIX & isReadOnce           & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isReadClean          & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isReadNotSharedDirty & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isReadShared         & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isReadUnique         & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isCleanInvalid       & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isMakeInvalid        & ~IS & ~PD      ) legal = 1;
    if (ssUC & esIX & isCleanShared        & ~IS & ~PD      ) legal = 1;

    if (ssUC & esSC & isReadOnce           &  IS & ~PD      ) legal = 1;
    if (ssUC & esSC & isReadClean          &  IS & ~PD      ) legal = 1;
    if (ssUC & esSC & isReadNotSharedDirty &  IS & ~PD      ) legal = 1;
    if (ssUC & esSC & isReadShared         &  IS & ~PD      ) legal = 1;
    if (ssUC & esSC & isCleanShared        &  IS & ~PD      ) legal = 1;

    if (ssUC & esUC & isReadOnce           &  IS & ~PD      ) legal = 1;
    if (ssUC & esUC & isCleanShared        &  IS & ~PD      ) legal = 1;

    if (ssUD & esIX & isReadOnce           & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isReadClean          & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isReadNotSharedDirty & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isReadShared         & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isReadUnique         & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isCleanInvalid       & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isMakeInvalid        & ~IS & ~PD & ~DT) legal = 1;
    if (ssUD & esIX & isMakeInvalid        & ~IS &  PD &  DT) legal = 1;
    if (ssUD & esIX & isCleanShared        & ~IS &  PD &  DT) legal = 1;

    if (ssUD & esSC & isReadOnce           &  IS &  PD &  DT) legal = 1;
    if (ssUD & esSC & isReadClean          &  IS &  PD &  DT) legal = 1;
    if (ssUD & esSC & isReadNotSharedDirty &  IS &  PD &  DT) legal = 1;
    if (ssUD & esSC & isReadShared         &  IS &  PD &  DT) legal = 1;
    if (ssUD & esSC & isCleanShared        &  IS &  PD &  DT) legal = 1;

    if (ssUD & esSD & isReadOnce           &  IS & ~PD &  DT) legal = 1;
    if (ssUD & esSD & isReadClean          &  IS & ~PD &  DT) legal = 1;
    if (ssUD & esSD & isReadNotSharedDirty &  IS & ~PD &  DT) legal = 1;
    if (ssUD & esSD & isReadShared         &  IS & ~PD &  DT) legal = 1;

    if (ssUD & esUD & isReadOnce           &  IS & ~PD &  DT) legal = 1;

    return legal;
endfunction : isLegalAceSnoopStateTransition 

////////////////////////////////////////////////////////////////////////////////
// genAceSnoopResults
////////////////////////////////////////////////////////////////////////////////

static function void genAceSnoopResults (aceState_t       start_state,
                                         eMsgACE          msg,
                                  output aceSnoopResult_t snoop_result [$],
                                  output aceState_t       ending_state [$]);

  aceState_t       end_state;
  aceSnoopResult_t result;
  aceSnoopResult_t result_tmp;
  int              qx [$];
  int              qy [$];

  snoop_result.delete();
  ending_state.delete();

  foreach (aceState_List[i]) begin
    end_state = aceState_List[i];

    foreach (aceLegalSnoopResult_List[i]) begin
      result_tmp = aceLegalSnoopResult_List[i]; // type conversion

      if (isLegalAceSnoopStateTransition (msg,
                                          result_tmp.IS,
                                          result_tmp.PD,
                                          result_tmp.DT,
                                          start_state,
                                          end_state)) begin
        qx = ending_state.find_first_index() with ( item == end_state);
        qy = snoop_result.find_first_index() with ( item == result_tmp);
        if (qx.size() && qy.size() && (qx[0] == qy[0])) begin
          // duplicate is found, don't push it to output list
        end else begin
          snoop_result.push_back(result_tmp);
          ending_state.push_back(end_state);
        end
      end

    end // foreach

  end // foreach

endfunction : genAceSnoopResults

////////////////////////////////////////////////////////////////////////////////
// generate all combinations of ACE states
////////////////////////////////////////////////////////////////////////////////

static function void genCombAceStates(aceState_t in_states [SYS_nSysAIUs][$], output aceState_t out_states [][SYS_nSysAIUs]);

  aceState_t     states [SYS_nSysAIUs];
  int            count  [SYS_nSysAIUs];
  int            total;

  total = 1;
  for (int i=0; i < SYS_nSysAIUs; i++) begin
    if (in_states[i].size()) begin
      total = total * in_states[i].size();
      count[i] = total;
    end
  end

  out_states = new[total];
  for (int i=0; i < total; i++) begin
    for (int c=0; c < SYS_nSysAIUs; c++) begin
      if (in_states[c].size) begin
        states[c] = in_states[c][(i / (count[c] / in_states[c].size)) % in_states[c].size];
      end
    end
    out_states[i] = states;
  end

endfunction : genCombAceStates

////////////////////////////////////////////////////////////////////////////////
// generate all combinations of ACE snoop results
////////////////////////////////////////////////////////////////////////////////

static function void genCombAceSnoopResults(aceSnoopResult_t in_states [SYS_nSysAIUs][$], output aceSnoopResult_t out_states [][SYS_nSysAIUs]);

  aceSnoopResult_t  states [SYS_nSysAIUs];
  int               count  [SYS_nSysAIUs];
  int               total;

  total = 1;
  for (int i=0; i < SYS_nSysAIUs; i++) begin
    if (in_states[i].size()) begin
      total = total * in_states[i].size();
      count[i] = total;
    end
  end

  out_states = new[total];
  for (int i=0; i < total; i++) begin
    for (int c=0; c < SYS_nSysAIUs; c++) begin
      if (in_states[c].size) begin
        states[c] = in_states[c][(i / (count[c] / in_states[c].size)) % in_states[c].size];
      end
    end
    out_states[i] = states;
  end

endfunction : genCombAceSnoopResults

////////////////////////////////////////////////////////////////////////////////
// generate ACE coherence results from ACE snoop results
////////////////////////////////////////////////////////////////////////////////
/*
static function void genAceCoherResultsFromSnoops(aceSnoopResult_t snoop_results [][SYS_nSysAIUs], output aceSnoopResult_t coher_results []);

  snoopResult_t    concerto_snoop_results [][SYS_nSysAIUs];
  coherResult_t    concerto_coher_result;
  aceSnoopResult_t coher_result;

  concerto_snoop_results = new[snoop_results.size()];
  coher_results = new[snoop_results.size()];

  for (int n = 0; n < snoop_results.size(); n++) begin

    concerto_coher_result.SS = 0;
    concerto_coher_result.SO = 0;
    concerto_coher_result.SD = 0;
    concerto_coher_result.ST = 0;

    for (int i = 0; i < SYS_nSysAIUs; i++) begin
      if (mapAceSnoopResult (snoop_results[n][i], concerto_snoop_results[n][i])) begin
        concerto_coher_result.SS = concerto_coher_result.SS | concerto_snoop_results[n][i].RV;
        concerto_coher_result.SO = concerto_coher_result.SO | concerto_snoop_results[n][i].RS;
        concerto_coher_result.SD = concerto_coher_result.SD | concerto_snoop_results[n][i].DC;
        concerto_coher_result.ST = concerto_coher_result.ST | concerto_snoop_results[n][i].DT;
      end
    end

    void'(mapConcertoSnoopResult(concerto_coher_result, coher_results[n]));
  end

endfunction : genAceCoherResultsFromSnoops
*/
////////////////////////////////////////////////////////////////////////////////
// generate transaction results and ending states
////////////////////////////////////////////////////////////////////////////////

static function void genAceCommandResults (
                             input  eMsgACE          msg,
                             input  aceSnoopResult_t coher,
                             output aceState_t       ending_state [$],
                             input  aceState_t       initial_state );

  aceState_t    end_state;
  int           qx [$];

  ending_state.delete();

  foreach (aceState_List [i]) begin
    end_state = aceState_List[i];
    if (isLegalAceCommandStateTransition(msg, coher.IS, coher.PD, initial_state, end_state)) begin
      qx = ending_state.find_first_index() with (item == end_state);
      if (qx.size()) begin
        // duplicate is found, don't push it to output list
      end else begin
        ending_state.push_back(end_state);
      end
    end
  end // foreach 
endfunction : genAceCommandResults

////////////////////////////////////////////////////////////////////////////////
// update ending state vector
////////////////////////////////////////////////////////////////////////////////

static function void genAceStatesFromReqAIUEndingStates(aceState_t initial_states [SYS_nSysAIUs],
                                                        AIUID_t    req_aiu_id,
                                                        aceState_t req_aiu_ending_states [],
                                                 output aceState_t ending_states  [][SYS_nSysAIUs]);

  ending_states = new[req_aiu_ending_states.size()];

  for (int i=0; i < req_aiu_ending_states.size(); i++) begin
    ending_states[i] = initial_states;
    ending_states[i][req_aiu_id] = req_aiu_ending_states[i];
  end

endfunction : genAceStatesFromReqAIUEndingStates


