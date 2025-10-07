////////////////////////////////////////////////////////////////////////////////
//
// Type Definitions
//
////////////////////////////////////////////////////////////////////////////////

typedef enum bit [2:0] {

  IX, SC, OC, OD, UC, UD

} cacheState_t;
/*
typedef struct {

  int            err_code;
  string         info;

} errCodeEntry_t;

////////////////////////////////////////////////////////////////////////////////
//
// Local Parameters
//
////////////////////////////////////////////////////////////////////////////////
*/
static cacheState_t Concerto_cacheState_List [] = 
    '{
        IX, SC, OC, OD, UC, UD
     };
/*
// ------------------------------------------------------------------
// RV  RS  DC  DT  Legal?  Notes
// ------------------------------------------------------------------
// 0   0   0   0   Yes     Copy is now IX from non-owned (IX|SC) state
// 0   0   0   1   Yes     Copy is now IX from non-owned (SC) state; clean data transfer
// 0   0   1   0   No      Cannot downgrade to clean from non-owned state
// 0   0   1   1   No      Cannot downgrade to clean from non-owned state
// 0   1   0   0   Yes     Copy is now IX from owned (OC|UC) state
// 0   1   0   1   Yes     Copy is now IX from owned (OC|UC) state; clean data transfer
// 0   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 0   1   1   1   Yes     Copy is now IX from owned (OD|UD) state; dirty data transfer
// 1   0   0   0   Yes     Copy is clean (SC|OC|UC); no owner/sharer change
// 1   0   0   1   Yes     Copy is valid; no owner/sharer change; clean data transfer
// 1   0   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   0   1   1   Yes     Copy is owned (OC|UC); no owner change; dirty data transfer
// 1   1   0   0   Yes     Copy is now SC from owned (OC|UC) state
// 1   1   0   1   Yes     Copy is now SC from owned (OC|UC) state; clean data transfer
// 1   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   1   1   1   Yes     Copy is now SC from owned (OD|UD) state; dirty data transfer
// ------------------------------------------------------------------
// Table 7: Legal Protocol Snoop Results
// ------------------------------------------------------------------
*/
localparam bit [3:0] Concerto_LegalSnoopResult_List [] =
    '{
      4'b0000,
      4'b0001,
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
/*
// -----------------------------------------------------------------
// Concerto  ACE    
// State     State
// -----------------------------------------------------------------
// IX        I         
// SC        SC
// OC        SC
// OD        SD
// UC        UC
// UD        UD
// -----------------------------------------------------------------
// Table: Concerto State and ACE State

// -----------------------------------------------------------------
//                    Legal Starting
// ACE Command        ACE State       Concerto Command
// -----------------------------------------------------------------
// ReadOnce           I,SC,SD,UC,UD   CmdRdCpy
// ReadClean          I,SC,SD,UC,UD   CmdRdVld
// ReadNotSharedDirty I,SC,SD,UC,UD   CmdRdVld
// ReadShared         I,SC,SD,UC,UD   CmdRdVld
// ReadUnique         I,SC,SD,UC,UD   CmdRdUnq
// CleanUnique        I,SC,SD,UC,UD   CmdClnUnq
// CleanShared        I,SC,   UC      CmdClnVld
// CleanInvalid       I               CmdClnInv
// MakeUnique         I,SC,SD,UC,UD   CmdClnUnq
// MakeInvalid        I               CmdClnInv
// WriteClean              SD,   UD   
// WriteUnique        I,SC,   UC      CmdWrUnqPtl
// WriteLineUnique    I,SC,   UC      CmdWrUnqFull
// WriteBack               SD,   UD   Upd
// Evict                SC,   UC      Upd
// -----------------------------------------------------------------
// Table: ACE command and legal starting ACE state

static eMsgCMD Concerto_CMDreq_List [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        //eCmdRdNc,
        eCmdClnUnq,
        eCmdClnVld,
        eCmdClnInv,
        eCmdWrUnqPtl,
        eCmdWrUnqFull,
        //eCmdWrNc,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_IX [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdClnVld,
        eCmdClnInv,
        eCmdWrUnqPtl,
        eCmdWrUnqFull,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_SC [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdClnVld,
        eCmdWrUnqPtl,
        eCmdWrUnqFull,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_OC [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdClnVld,
        eCmdWrUnqPtl,
        eCmdWrUnqFull,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_OD [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_UC [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdClnVld,
        eCmdWrUnqPtl,
        eCmdWrUnqFull,
        eCmdDvmMsg
     };

static eMsgCMD Concerto_CMDreq_List_In_UD [] =
    '{
        //eCmdRdCpy,
        eCmdRdCln,
        eCmdRdVld,
        eCmdRdUnq,
        eCmdClnUnq,
        eCmdDvmMsg
     };

static eMsgSNP Concerto_SNPreq_List [] =
    '{
        eSnpClnDtr,
        eSnpVldDtr,
        eSnpInvDtr,
        eSnpInvDtw,
        eSnpClnDtw,
        eSnpInv,
        eSnpDvmMsg
     };

////////////////////////////////////////////////////////////////////////////////
//
// Utility Functions
//
////////////////////////////////////////////////////////////////////////////////

// Make a CMDreq Message Type

static function eMsgCMD makeCmdMsgType ();
    eMsgCMD m;
    case ($urandom() % m.num())
      0 : m = eCmdRdCpy;
      1 : m = eCmdRdVld;
      2 : m = eCmdRdUnq;
      3 : m = eCmdClnUnq;
      4 : m = eCmdClnVld;
      5 : m = eCmdClnInv;
      6 : m = eCmdWrUnqPtl;
      7 : m = eCmdWrUnqFull;
    endcase
    return m;
endfunction : makeCmdMsgType

// Make a SNPreq Message Type

static function eMsgSNP makeSnpMsgType ();
    eMsgSNP m;
    case ($urandom() % m.num())
      0 : m = eSnpClnDtr;
      1 : m = eSnpVldDtr;
      2 : m = eSnpInvDtr;
      3 : m = eSnpInvDtw;
      4 : m = eSnpClnDtw;
      5 : m = eSnpInv;
    endcase
    return m;
endfunction : makeSnpMsgType

// Make a cacheline address that is randomized

static function cacheAddress_t makeCacheAddress ();
    cacheAddress_t addr;
    addr = {$urandom(), $urandom()};
    return addr;
endfunction : makeCacheAddress

// Make a cacheline address mask

static function cacheAddress_t makeCacheAddressMask ();
    cacheAddress_t addr = SYS_nSysCacheline - 1;
    return (~addr);
endfunction : makeCacheAddressMask

// Make a cacheline state that is randomized to one of legal states

static function cacheState_t makeCacheState ();
    cacheState_t state;
    case ($urandom() % state.num())
      IX : state = IX;
      SC : state = SC;
      OC : state = OC;
      OD : state = OD;
      UC : state = UC;
      UD : state = UD;
    endcase
    return state;
endfunction : makeCacheState

// Make a data structure entry comprising cacheline states of AIUs

static function void makeCacheStates (output cacheState_t states [SYS_nSysAIUs]);
    foreach (states[i]) begin
      states[i] = makeCacheState();
    end
endfunction : makeCacheStates

// -----------------------------------------------------------------
// I/V  N/O  S/U  C/D Concerto  Standard  Notes
//                    State     State
// -----------------------------------------------------------------
//  I    -    -    -  IX        Invalid   Others: IX|SC|OC|OD|UC|UD
//  V    N    S    C  SC        Shared    Others: IX|SC|OC|OD
//  V    O    S    C  OC        Forward   Others: IX|SC
//  V    O    S    D  OD        Owned     Others: IX|SC
//  V    O    U    C  UC        Exclusive Others: IX
//  V    O    U    D  UD        Modified  Others: IX
// ------------------------------------------------------------------
// Table 1: Concerto Generic Caching Model
// -----------------------------------------------------------------

// Check if the cacheline states of AIUs is legal

static function bit isLegalCacheStates (cacheState_t states [SYS_nSysAIUs] );
    cacheState_t i_state;
    cacheState_t j_state;
    for (int i = 0; i < SYS_nSysAIUs; i++) begin
      i_state = states[i]; // reference state
      for (int j = i+1; j < SYS_nSysAIUs; j++) begin
        j_state = states[j]; // others state
        case (i_state)
          UD, UC :
            begin
              if (!(j_state inside { IX })) return 0;
            end
          OD, OC :
            begin
              if (!(j_state inside { IX, SC })) return 0;
            end
          SC :
            begin
              if (!(j_state inside { IX, SC, OC, OD })) return 0;
            end
          IX :
            begin
              if (!(j_state inside { IX, SC, OC, OD, UC, UD })) return 0;
            end
        endcase
      end
    end
    return 1;
endfunction : isLegalCacheStates 

// Make a legal cacheline states of AIUs

static function void makeLegalCacheStates (output cacheState_t states [SYS_nSysAIUs]);
    do begin
      makeCacheStates (states);
    end while (!isLegalCacheStates (states));
endfunction : makeLegalCacheStates;

// ------------------------------------------------------------------
// RV  RS  DC  DT  Legal?  Notes
// ------------------------------------------------------------------
// 0   0   0   0   Yes     Copy is now IX from non-owned (IX|SC) state
// 0   0   0   1   Yes     Copy is now IX from non-owned (SC) state; clean data transfer
// 0   0   1   0   No      Cannot downgrade to clean from non-owned state
// 0   0   1   1   No      Cannot downgrade to clean from non-owned state
// 0   1   0   0   Yes     Copy is now IX from owned (OC|UC) state
// 0   1   0   1   Yes     Copy is now IX from owned (OC|UC) state; clean data transfer
// 0   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 0   1   1   1   Yes     Copy is now IX from owned (OD|UD) state; dirty data transfer
// 1   0   0   0   Yes     Copy is clean (SC|OC|UC); no owner/sharer change
// 1   0   0   1   Yes     Copy is valid; no owner/sharer change; clean data transfer
// 1   0   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   0   1   1   Yes     Copy is owned (OC|UC); no owner change; dirty data transfer
// 1   1   0   0   Yes     Copy is now SC from owned (OC|UC) state
// 1   1   0   1   Yes     Copy is now SC from owned (OC|UC) state; clean data transfer
// 1   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   1   1   1   Yes     Copy is now SC from owned (OD|UD) state; dirty data transfer
// ------------------------------------------------------------------
// Table 7: Legal Protocol Snoop Results
// ------------------------------------------------------------------

// Check if a given snoop result is legal 

static function bit isLegalSnoopResult (bit RV, bit RS, bit DC, bit DT);
    bit legal;
    legal = 0;
    case ({RV, RS, DC, DT})
      4'b0000 : legal = 1;
      4'b0001 : legal = 1;
      4'b0010 : legal = 0;
      4'b0011 : legal = 0;
      4'b0100 : legal = 1;
      4'b0101 : legal = 1;
      4'b0110 : legal = 0;
      4'b0111 : legal = 1;
      4'b1000 : legal = 1;
      4'b1001 : legal = 1;
      4'b1010 : legal = 0;
      4'b1011 : legal = 1;
      4'b1100 : legal = 1;
      4'b1101 : legal = 1;
      4'b1110 : legal = 0;
      4'b1111 : legal = 1;
    endcase
    return legal;
endfunction : isLegalSnoopResult

// Make a legal snoop result

static function bit [3:0] makeLegalSnoopResult ();
    bit [3:0] v;
    do begin
      v = $urandom() & 4'b1111;
    end while (!isLegalSnoopResult (v[3],v[2],v[1],v[0]));
    return v;
endfunction : makeLegalSnoopResult

// In general, snoops never upgrade cacheline properties; in other words, the
// state of a cacheline may remain unchanged, or its properties may transition
// from valid to invalid, owned to non-owned, unique to shared, and/or dirty to
// clean.
//
// Table 10 lists the possible cache state transitions and whether the
// transition is legal in combination with a given SNPreq message, followed by
// the corresponding protocol snoop results generated by the caching agent for
// a legal combination.
//
// In the column headings below, SS represents the starting cache state while
// ES represents the ending cache state. Values in parentheses for RS and DT
// are the expected snoop result, but the inverse result is also legal.
// The SNPreq messages are represented as follows:
//
// CDR - Snoop Clean with Data Reply (SnpClnDtr)
// VDR - Snoop Valid with Data Reply (SnpVldDtr)
// IDR - Snoop Invalid with Data Reply (SnpInvDtr)
// VDW - Snoop Valid with Data Write (SnpClnDtw)
// IDW - Snoop Invalid with Data Write (SnpInvDtw)
// RCL - Snoop Recall (SnpRecall)
// INV - Snoop Invalid (SnpInv)
//
// ------------------------------------------------------------------
// Table 10: Legal Cache State Transitions and Snoop Results due to Snoop Messages
// ------------------------------------------------------------------

static function bit isLegalSnoopStateTransition (
    input  eMsgSNP      msg,
    input  bit          RV,
    input  bit          RS,
    input  bit          DC,
    input  bit          DT,
    input  cacheState_t startingState,
    input  cacheState_t endingState
);
    bit       legal;
    bit       isCDR;
    bit       isVDR;
    bit       isIDR;
    bit       isVDW;
    bit       isIDW;
    bit       isINV;
    bit       ssIX;
    bit       ssSC;
    bit       ssOC;
    bit       ssOD;
    bit       ssUC;
    bit       ssUD;
    bit       esIX;
    bit       esSC;
    bit       esOC;
    bit       esOD;
    bit       esUC;
    bit       esUD;

    legal = 0;

    isCDR = (msg == eSnpClnDtr) ? 1 : 0;
    isVDR = (msg == eSnpVldDtr) ? 1 : 0;
    isIDR = (msg == eSnpInvDtr) ? 1 : 0;
    isVDW = (msg == eSnpClnDtw) ? 1 : 0;
    isIDW = (msg == eSnpInvDtw) ? 1 : ((msg == eSnpRecall) ? 1 : 0);
    isINV = (msg == eSnpInv   ) ? 1 : 0;

    ssIX  = (startingState == IX) ? 1 : 0;
    ssSC  = (startingState == SC) ? 1 : 0;
    ssOC  = (startingState == OC) ? 1 : 0;
    ssOD  = (startingState == OD) ? 1 : 0;
    ssUC  = (startingState == UC) ? 1 : 0;
    ssUD  = (startingState == UD) ? 1 : 0;

    esIX  = (endingState == IX) ? 1 : 0;
    esSC  = (endingState == SC) ? 1 : 0;
    esOC  = (endingState == OC) ? 1 : 0;
    esOD  = (endingState == OD) ? 1 : 0;
    esUC  = (endingState == UC) ? 1 : 0;
    esUD  = (endingState == UD) ? 1 : 0;

// SS  ES  CDR  VDR  IDR  VDW  IDW  INV  RV  RS  DC  DT
// -----------------------------------------------------
// IX  IX  Yes  Yes  Yes  Yes  Yes  Yes  0   0   0   0

    if (ssIX & esIX & isCDR & ~RV & ~RS & ~DC & ~DT) legal = 1;
    if (ssIX & esIX & isVDR & ~RV & ~RS & ~DC & ~DT) legal = 1;
    if (ssIX & esIX & isIDR & ~RV & ~RS & ~DC & ~DT) legal = 1;
    if (ssIX & esIX & isVDW & ~RV & ~RS & ~DC & ~DT) legal = 1;
    if (ssIX & esIX & isIDW & ~RV & ~RS & ~DC & ~DT) legal = 1;
    if (ssIX & esIX & isINV & ~RV & ~RS & ~DC & ~DT) legal = 1;


// SS  ES  CDR  VDR  IDR  VDW  IDW  INV  RV  RS  DC  DT
// -----------------------------------------------------
// SC  IX  Yes  Yes  Yes  Yes  Yes  Yes  0   0   0  (0)
//     SC  Yes  Yes  No   Yes  No   No   1   0   0  (0)

    if (ssSC & esIX & isCDR & ~RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esIX & isVDR & ~RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esIX & isIDR & ~RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esIX & isVDW & ~RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esIX & isIDW & ~RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esIX & isINV & ~RV & ~RS & ~DC      ) legal = 1;

    if (ssSC & esSC & isCDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esSC & isVDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esSC & isIDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssSC & esSC & isVDW &  RV & ~RS & ~DC      ) legal = 1;
    if (ssSC & esSC & isIDW &  RV & ~RS & ~DC      ) legal = 0;
    if (ssSC & esSC & isINV &  RV & ~RS & ~DC      ) legal = 0;

// SS  ES  CDR   VDR   IDR   VDW   IDW   INV   RV  RS  DC  DT
// --------------------------------------------------------------
// OC  IX  No    No    No    No    No    Yes   0  (1)  0  (0)
//     IX  Yes   Yes   Yes   Yes   Yes   Yes   0  (1)  0  (1)
//     SC  Yes   Yes   No    Yes   No    No    1  (1)  0  (1)
//     OC  Yes   Yes   No    Yes   No    No    1   0   0  (1)

    if (ssOC & esIX & isCDR & ~RV       & ~DC      ) legal = 1;
    if (ssOC & esIX & isVDR & ~RV       & ~DC      ) legal = 1;
    if (ssOC & esIX & isIDR & ~RV       & ~DC      ) legal = 1;
    if (ssOC & esIX & isVDW & ~RV       & ~DC      ) legal = 1;
    if (ssOC & esIX & isIDW & ~RV       & ~DC      ) legal = 1;
    if (ssOC & esIX & isINV & ~RV       & ~DC      ) legal = 1;

    if (ssOC & esSC & isCDR &  RV       & ~DC      ) legal = 1;
    if (ssOC & esSC & isVDR &  RV       & ~DC      ) legal = 1;
    if (ssOC & esSC & isIDR &  RV       & ~DC      ) legal = 0;
    if (ssOC & esSC & isVDW &  RV       & ~DC      ) legal = 1;
    if (ssOC & esSC & isIDW &  RV       & ~DC      ) legal = 0;
    if (ssOC & esSC & isINV &  RV       & ~DC      ) legal = 0;

    if (ssOC & esOC & isCDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssOC & esOC & isVDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssOC & esOC & isIDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssOC & esOC & isVDW &  RV & ~RS & ~DC      ) legal = 1;
    if (ssOC & esOC & isIDW &  RV & ~RS & ~DC      ) legal = 0;
    if (ssOC & esOC & isINV &  RV & ~RS & ~DC      ) legal = 0;

// SS  ES  CDR   VDR   IDR   VDW   IDW   INV   RV  RS  DC  DT
// -----------------------------------------------------------
// OD  IX  No    No    No    No    No    Yes   0  (1)  0  (0)
//         Yes   Yes   Yes   Yes   Yes   Yes   0   1   1   1
//     SC  Yes   Yes   No    Yes   No    No    1   1   1   1
//     OC  No    No    No    Yes   No    No    1   0   1   1
//     OD  Yes   Yes   No    No    No    No    1   0   0   1

    if (ssOD & esIX & isCDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssOD & esIX & isVDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssOD & esIX & isIDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssOD & esIX & isVDW & ~RV       & ~DC & ~DT) legal = 0;
    if (ssOD & esIX & isIDW & ~RV       & ~DC & ~DT) legal = 0;
    if (ssOD & esIX & isINV & ~RV       & ~DC & ~DT) legal = 1;

    if (ssOD & esIX & isCDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esIX & isVDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esIX & isIDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esIX & isVDW & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esIX & isIDW & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esIX & isINV & ~RV &  RS &  DC &  DT) legal = 1;

    if (ssOD & esSC & isCDR &  RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esSC & isVDR &  RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esSC & isIDR &  RV &  RS &  DC &  DT) legal = 0;
    if (ssOD & esSC & isVDW &  RV &  RS &  DC &  DT) legal = 1;
    if (ssOD & esSC & isIDW &  RV &  RS &  DC &  DT) legal = 0;
    if (ssOD & esSC & isINV &  RV &  RS &  DC &  DT) legal = 0;

    if (ssOD & esOC & isCDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssOD & esOC & isVDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssOD & esOC & isIDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssOD & esOC & isVDW &  RV & ~RS &  DC &  DT) legal = 1;
    if (ssOD & esOC & isIDW &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssOD & esOC & isINV &  RV & ~RS &  DC &  DT) legal = 0;

    if (ssOD & esOD & isCDR &  RV & ~RS & ~DC &  DT) legal = 1;
    if (ssOD & esOD & isVDR &  RV & ~RS & ~DC &  DT) legal = 1;
    if (ssOD & esOD & isIDR &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssOD & esOD & isVDW &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssOD & esOD & isIDW &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssOD & esOD & isINV &  RV & ~RS & ~DC &  DT) legal = 0;

// SS  ES  CDR  VDR  IDR  VDW  IDW  INV  RV  RS  DC  DT
// -----------------------------------------------------------
// UC  IX  No   No   No   No   No   Yes  0  (1)  0  (0)
//     IX  Yes  Yes  Yes  Yes  Yes  Yes  0  (1)  0  (1)
//     SC  Yes  Yes  No   Yes  No   No   1  (1)  0  (1)
//     OC  Yes  Yes  No   Yes  No   No   1   0   0  (1)
//     UC  No   No   No   Yes  No   No   1   0   0  (1)

    if (ssUC & esIX & isCDR & ~RV       & ~DC      ) legal = 1;
    if (ssUC & esIX & isVDR & ~RV       & ~DC      ) legal = 1;
    if (ssUC & esIX & isIDR & ~RV       & ~DC      ) legal = 1;
    if (ssUC & esIX & isVDW & ~RV       & ~DC      ) legal = 1;
    if (ssUC & esIX & isIDW & ~RV       & ~DC      ) legal = 1;
    if (ssUC & esIX & isINV & ~RV       & ~DC      ) legal = 1;

    if (ssUC & esSC & isCDR &  RV       & ~DC      ) legal = 1;
    if (ssUC & esSC & isVDR &  RV       & ~DC      ) legal = 1;
    if (ssUC & esSC & isIDR &  RV       & ~DC      ) legal = 0;
    if (ssUC & esSC & isVDW &  RV       & ~DC      ) legal = 1;
    if (ssUC & esSC & isIDW &  RV       & ~DC      ) legal = 0;
    if (ssUC & esSC & isINV &  RV       & ~DC      ) legal = 0;

    if (ssUC & esOC & isCDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssUC & esOC & isVDR &  RV & ~RS & ~DC      ) legal = 1;
    if (ssUC & esOC & isIDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esOC & isVDW &  RV & ~RS & ~DC      ) legal = 1;
    if (ssUC & esOC & isIDW &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esOC & isINV &  RV & ~RS & ~DC      ) legal = 0;

    if (ssUC & esUC & isCDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esUC & isVDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esUC & isIDR &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esUC & isVDW &  RV & ~RS & ~DC      ) legal = 1;
    if (ssUC & esUC & isIDW &  RV & ~RS & ~DC      ) legal = 0;
    if (ssUC & esUC & isINV &  RV & ~RS & ~DC      ) legal = 0;

// SS  ES  CDR  VDR  IDR  VDW  IDW  INV  RV  RS  DC  DT
// ------------------------------------------------------------------
// UD  IX  No   No   No   No   No   Yes  0  (1)  0  (0)
//         Yes  Yes  Yes  Yes  Yes  Yes  0   1   1   1
//     SC  Yes  Yes  No   Yes  No   No   1   1   1   1
//     OC  No   No   No   Yes  No   No   1   0   1   1
//     OD  Yes  Yes  No   No   No   No   1   0   0   1
//     UC  No   No   No   Yes  No   No   1   0   1   1
//     UD  No   No   No   No   No   No   -   -   -   -

    if (ssUD & esIX & isCDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssUD & esIX & isVDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssUD & esIX & isIDR & ~RV       & ~DC & ~DT) legal = 0;
    if (ssUD & esIX & isVDW & ~RV       & ~DC & ~DT) legal = 0;
    if (ssUD & esIX & isIDW & ~RV       & ~DC & ~DT) legal = 0;
    if (ssUD & esIX & isINV & ~RV       & ~DC & ~DT) legal = 1;

    if (ssUD & esIX & isCDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esIX & isVDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esIX & isIDR & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esIX & isVDW & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esIX & isIDW & ~RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esIX & isINV & ~RV &  RS &  DC &  DT) legal = 1;

    if (ssUD & esSC & isCDR &  RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esSC & isVDR &  RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esSC & isIDR &  RV &  RS &  DC &  DT) legal = 0;
    if (ssUD & esSC & isVDW &  RV &  RS &  DC &  DT) legal = 1;
    if (ssUD & esSC & isIDW &  RV &  RS &  DC &  DT) legal = 0;
    if (ssUD & esSC & isINV &  RV &  RS &  DC &  DT) legal = 0;

    if (ssUD & esOC & isCDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esOC & isVDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esOC & isIDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esOC & isVDW &  RV & ~RS &  DC &  DT) legal = 1;
    if (ssUD & esOC & isIDW &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esOC & isINV &  RV & ~RS &  DC &  DT) legal = 0;

    if (ssUD & esOD & isCDR &  RV & ~RS & ~DC &  DT) legal = 1;
    if (ssUD & esOD & isVDR &  RV & ~RS & ~DC &  DT) legal = 1;
    if (ssUD & esOD & isIDR &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssUD & esOD & isVDW &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssUD & esOD & isIDW &  RV & ~RS & ~DC &  DT) legal = 0;
    if (ssUD & esOD & isINV &  RV & ~RS & ~DC &  DT) legal = 0;

    if (ssUD & esUC & isCDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esUC & isVDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esUC & isIDR &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esUC & isVDW &  RV & ~RS &  DC &  DT) legal = 1;
    if (ssUD & esUC & isIDW &  RV & ~RS &  DC &  DT) legal = 0;
    if (ssUD & esUC & isINV &  RV & ~RS &  DC &  DT) legal = 0;

    return legal;
endfunction : isLegalSnoopStateTransition 

// State Reply (StrState)
//
// State Reply message indicates the completion of all coherence operations and
// provides the protocol coherence result to the requesting AIU.  The protocol
// coherence result consists of the following summary fields:
//
// Summary Valid (SS) - At least one other agent has retained a valid copy of the cacheline
// Summary Owned (SO) - The requesting AIU may pass ownership to its caching agent
// Summary Dirty (SD) - The requesting AIU may install a dirty copy in its caching agent
// Summary Transfers (ST) - The count of expected data transfers to the requesting AIU
//
// Table 12 lists the legal ending cache states (IX, SC, etc.) into which a
// caching agent may install the cacheline copy based on the protocol coherence
// result (SS, SO, SD, and ST).
//
// ------------------------------------------------------------------
// SS  SO  SD  ST  IX     SC     OC    OD   UC    UD   Notes
// ------------------------------------------------------------------
// 0   x   0   x   Yes    Yes    Yes   No   Yes   No   No shared copies
// 0   x   1   1+ *Yes*  *Yes*  *Yes*  Yes *Yes*  Yes  No shared copies
// 1   0   0   x   Yes    Yes     No   No   No    No
// 1   0   1   1+ *Yes*  *Yes*    No   No   No    No
// 1   1   0   x   Yes    Yes    Yes   No   No    No
// 1   1   1   1+ *Yes*  *Yes*  *Yes*  Yes  No    No
// ------------------------------------------------------------------
// Table 18: Legal Ending Cache States
//
// Note:  The assertion of SD implies the assertion of SO when SS equals 0. 
// In addition, the assertion of SD also implies that ST is greater than zero,
// signified by "1+" in the above table.
//
// Cells denoted with "*Yes*" require the requesting AIU to update memory with a
// DTWreq message before installing the cacheline in the given state. 
// The requesting AIU assumes an installed cache state based on the legal ending
// cache states, the allowed ending cache states, and the original protocol
// transaction (see Section 4.3.1).

static function bit isLegalSTRreqEndingState (
    input  coherResult_t coher_result,
    input  cacheState_t endingState,
    output bit          isReqAIUToUpdateMem
);
    bit  legal;

    bit  SS;
    bit  SO;
    bit  SD;
    bit  ST;

    bit  esIX;
    bit  esSC;
    bit  esOC;
    bit  esOD;
    bit  esUC;
    bit  esUD;

    legal = 0;

    SS = coher_result.SS;
    SO = coher_result.SO;
    SD = coher_result.SD;
    ST = |coher_result.ST;

    esIX  = (endingState == IX) ? 1 : 0;
    esSC  = (endingState == SC) ? 1 : 0;
    esOC  = (endingState == OC) ? 1 : 0;
    esOD  = (endingState == OD) ? 1 : 0;
    esUC  = (endingState == UC) ? 1 : 0;
    esUD  = (endingState == UD) ? 1 : 0;

// ------------------------------------------------------------------
// SS  SO  SD  ST  IX     SC     OC    OD   UC    UD   Notes
// ------------------------------------------------------------------
// 0   x   0   x   Yes    Yes    Yes   No   Yes   No   No share
// 0   x   1   1+ *Yes*  *Yes*  *Yes*  Yes *Yes*  Yes  No share
// 1   0   0   x   Yes    Yes     No   No   No    No
// 1   0   1   1+ *Yes*  *Yes*    No   No   No    No
// 1   1   0   x   Yes    Yes    Yes   No   No    No
// 1   1   1   1+ *Yes*  *Yes*  *Yes*  Yes  No    No
// ------------------------------------------------------------------

    if (~SS       & ~SD       & esIX) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if (~SS       & ~SD       & esSC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if (~SS       & ~SD       & esOC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if (~SS       & ~SD       & esOD) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if (~SS       & ~SD       & esUC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if (~SS       & ~SD       & esUD) begin legal = 0; isReqAIUToUpdateMem = 0; end

    if (~SS       &  SD &  ST & esIX) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if (~SS       &  SD &  ST & esSC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if (~SS       &  SD &  ST & esOC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if (~SS       &  SD &  ST & esOD) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if (~SS       &  SD &  ST & esUC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if (~SS       &  SD &  ST & esUD) begin legal = 1; isReqAIUToUpdateMem = 0; end

    if ( SS & ~SO & ~SD       & esIX) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO & ~SD       & esSC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO & ~SD       & esOC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO & ~SD       & esOD) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO & ~SD       & esUC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO & ~SD       & esUD) begin legal = 0; isReqAIUToUpdateMem = 0; end

    if ( SS & ~SO &  SD &  ST & esIX) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if ( SS & ~SO &  SD &  ST & esSC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if ( SS & ~SO &  SD &  ST & esOC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO &  SD &  ST & esOD) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO &  SD &  ST & esUC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS & ~SO &  SD &  ST & esUD) begin legal = 0; isReqAIUToUpdateMem = 0; end

    if ( SS &  SO & ~SD       & esIX) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO & ~SD       & esSC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO & ~SD       & esOC) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO & ~SD       & esOD) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO & ~SD       & esUC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO & ~SD       & esUD) begin legal = 0; isReqAIUToUpdateMem = 0; end

    if ( SS &  SO &  SD &  ST & esIX) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if ( SS &  SO &  SD &  ST & esSC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if ( SS &  SO &  SD &  ST & esOC) begin legal = 1; isReqAIUToUpdateMem = 1; end
    if ( SS &  SO &  SD &  ST & esOD) begin legal = 1; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO &  SD &  ST & esUC) begin legal = 0; isReqAIUToUpdateMem = 0; end
    if ( SS &  SO &  SD &  ST & esUD) begin legal = 0; isReqAIUToUpdateMem = 0; end

    return legal;
endfunction : isLegalSTRreqEndingState 

// A STRrsp message indicates the completion of the protocol transaction and
// provides the protocol transaction result to the Home DCE.  The transaction
// result consists of two bits, DO (Directory Owner) and DS (Directory Sharer),
// to indicate whether to track the associated caching agent as the cacheline
// owner or a cacheline sharer, as shown in Table 16.
//
// ------------------------------------------------------------------
// Implied State   TR=DO/DS Notes
// ------------------------------------------------------------------
// IX               0   0   Invalidate requesting agent
// SC               0   1   Allocate or designate requesting agent as sharer
// OC|OD|UC|UD      1   0   Allocate or designate requesting agent as owner
// -                1   1   Reserved
// ------------------------------------------------------------------
// Table 19: Implied Cache States and Protocol Transaction Reults
// ------------------------------------------------------------------

static function bit isLegalSTRrspInstalledState (
    input bit DO,
    input bit DS,
    input cacheState_t installedState 
);
    bit legal;
    bit isIX;
    bit isSC;
    bit isOC;
    bit isOD;
    bit isUC;
    bit isUD;

    legal = 0;

    isIX  = (installedState == IX) ? 1 : 0;
    isSC  = (installedState == SC) ? 1 : 0;
    isOC  = (installedState == OC) ? 1 : 0;
    isOD  = (installedState == OD) ? 1 : 0;
    isUC  = (installedState == UC) ? 1 : 0;
    isUD  = (installedState == UD) ? 1 : 0;

    if (isIX & ~DO & ~DS) legal = 1;

    if (isSC & ~DO &  DS) legal = 1;

    if (isOC &  DO & ~DS) legal = 1;
    if (isOD &  DO & ~DS) legal = 1;
    if (isUC &  DO & ~DS) legal = 1;
    if (isUD &  DO & ~DS) legal = 1;

    return legal;
endfunction : isLegalSTRrspInstalledState 

//
// See Table 59 also
//
static function bit [1:0] makeSTRrsp (
    input cacheState_t installedState
);
    bit DO;
    bit DS;
    case (installedState)
      IX : begin DO = 0; DS = 0; end
      SC : begin DO = 0; DS = 1; end
      OC : begin DO = 1; DS = 0; end
      OD : begin DO = 1; DS = 0; end
      UC : begin DO = 1; DS = 0; end
      UD : begin DO = 1; DS = 0; end
    endcase
    return {DO, DS};
endfunction : makeSTRrsp;

<%if(obj.isBridgeInterface && obj.useIoCache) { %> 

static function bit isLegalSTRreqResultForCmd (

    input  eMsgCMD cmd,
    input  coherResult_t coher_result,
    input  cacheState_t  installed_state,
    input  transResult_t trans_result,
    input  cacheState_t  initial_state = IX,
    output bit  is_dtw_data,
    output bit  is_dtw_none
);
  bit legal;
  bit iSS;
  bit iSO;
  bit iSD;
  bit iST;
  bit inst_IX;
  bit inst_SC;
  bit inst_OC;
  bit inst_UC;
  bit inst_OD;
  bit inst_UD;
  bit DO;
  bit DS;

  legal            = 0;
  is_dtw_data      = 0;
  is_dtw_none      = 0;

  DO = trans_result.DO;
  DS = trans_result.DS;

  iSS = coher_result.SS;
  iSO = coher_result.SO;
  iSD = coher_result.SD;
  iST = |coher_result.ST;

  inst_IX = (installed_state == IX) ? 1 : 0;
  inst_SC = (installed_state == SC) ? 1 : 0;
  inst_OC = (installed_state == OC) ? 1 : 0;
  inst_UC = (installed_state == UC) ? 1 : 0;
  inst_OD = (installed_state == OD) ? 1 : 0;
  inst_UD = (installed_state == UD) ? 1 : 0;

  case (cmd)

//  eCmdRdCpy : begin
//
//    if (  iSD & inst_IX & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end
//    if ( ~iSD & inst_IX & ~DO &  DS) legal = 1;
//  end

<% if(obj.DutInfo.fnCacheStates == "MSI-IX"){%>
    eCmdRdCln : begin
        if (~iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1; 
        if ( iSO &  iSS & ~iSD & inst_SC &  DO & ~DS) legal = 1;
        if ( iSO &  iSS &  iSD & inst_SC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
        if ( iSO & ~iSS & ~iSD & inst_SC &  DO & ~DS) legal = 1;
        if ( iSO & ~iSS &  iSD & inst_UD &  DO & ~DS) legal = 1;
  
    end
   
    eCmdRdUnq : begin
        if ( DO & ~DS) legal = 1;
    end

    eCmdClnUnq : begin
        if ( DO & ~DS) legal = 1;
    end

<%}else if(obj.DutInfo.fnCacheStates == "MEI"){%>
   
    eCmdRdUnq : begin
                if ( ~iSD && inst_UC & DO & ~DS) legal = 1;
                if (  iSD && inst_UD & DO & ~DS) legal = 1;
                if ( ~iSD && inst_UD & DO & ~DS) legal = 1;
    end

    eCmdClnUnq : begin
        if (  DO & ~DS) legal = 1;
    end

<%}%>

    eCmdWrUnqPtl, eCmdWrUnqFull : begin
        if (~DO & ~DS) begin legal = 1; is_dtw_data = 1; end
    end

  endcase

    if (iSD        & ~iST) legal = 0; // when SD=1, then ST must be 1+

    return legal;
endfunction : isLegalSTRreqResultForCmd


<%}else{%>


static function bit isLegalSTRreqResultForCmd (

    input  eMsgCMD cmd,
    input  coherResult_t coher_result,
    input  cacheState_t  installed_state,
    input  transResult_t trans_result,
    input  cacheState_t  initial_state = IX,
    output bit  is_dtw_data,
    output bit  is_dtw_none
);
  bit legal;
  bit iSS;
  bit iSO;
  bit iSD;
  bit iST;
  bit inst_IX;
  bit inst_SC;
  bit inst_OC;
  bit inst_UC;
  bit inst_OD;
  bit inst_UD;
  bit DO;
  bit DS;

  legal            = 0;
  is_dtw_data      = 0;
  is_dtw_none      = 0;

  DO = trans_result.DO;
  DS = trans_result.DS;

  iSS = coher_result.SS;
  iSO = coher_result.SO;
  iSD = coher_result.SD;
  iST = |coher_result.ST;

  inst_IX = (installed_state == IX) ? 1 : 0;
  inst_SC = (installed_state == SC) ? 1 : 0;
  inst_OC = (installed_state == OC) ? 1 : 0;
  inst_UC = (installed_state == UC) ? 1 : 0;
  inst_OD = (installed_state == OD) ? 1 : 0;
  inst_UD = (installed_state == UD) ? 1 : 0;

  case (cmd)

//  eCmdRdCpy : begin
//
//    if (~iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
//    if ( iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
//    if ( iSO &  iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
//    if ( iSO &  iSS &  iSD & inst_SC & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end
//    if ( iSO &  iSS &  iSD & inst_OC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
//    if ( iSO & ~iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
//    if ( iSO & ~iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
//    if ( iSO & ~iSS & ~iSD & inst_UC &  DO & ~DS) legal = 1;
//    if ( iSO & ~iSS &  iSD & inst_SC & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end
//    if ( iSO & ~iSS &  iSD & inst_OC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
//    if ( iSO & ~iSS &  iSD & inst_UC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
//
//  end

  eCmdRdCln, eCmdRdVld, eCmdRdUnq : begin

    if (~iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO &  iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
    if ( iSO &  iSS &  iSD & inst_SC & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO &  iSS &  iSD & inst_OC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO &  iSS &  iSD & inst_OD &  DO & ~DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_UC &  DO & ~DS) legal = 1;
    if ( iSO & ~iSS &  iSD & inst_SC & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO & ~iSS &  iSD & inst_OC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO & ~iSS &  iSD & inst_UC &  DO & ~DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO & ~iSS &  iSD & inst_UD &  DO & ~DS) legal = 1;

  end

  eCmdClnUnq : begin

    if ( iSO & ~iSS & ~iSD & inst_UC &  DO & ~DS) legal = 1;

  end

  eCmdClnVld : begin

    if (~iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO &  iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO &  iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_SC & ~DO &  DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_OC &  DO & ~DS) legal = 1;
    if ( iSO & ~iSS & ~iSD & inst_UC &  DO & ~DS) legal = 1;

  end

  eCmdClnInv : begin

    if ( iSO & ~iSS & ~iSD & inst_IX & ~DO & ~DS) legal = 1;

  end

  eCmdWrUnqPtl, eCmdWrUnqFull : begin

    if ( iSO & ~iSS & ~iSD & inst_IX & ~DO & ~DS) begin legal = 1; is_dtw_data = 1; end
    if ( iSO & ~iSS & ~iSD & inst_SC & ~DO &  DS) begin legal = 1; is_dtw_data = 1; end

  end

  endcase

    if (iSD        & ~iST) legal = 0; // when SD=1, then ST must be 1+

    return legal;
endfunction : isLegalSTRreqResultForCmd

<%}%>

// ------------------------------------------------------------------
// RV  RS |  O[d]   S[d]   Notes  
// ------------------------------------------------------------------
// 0   x  |   0      0    Remove from owner vector and from sharer vector
// 1   0  |  ---    ---   No change
// 1   1  |   0      V    Remove from owner vector and add to sharer vector if valid
// ------------------------------------------------------------------
// Table 70: Active Owner and Sharer Vector Transitions for a Snooped Agent
// ------------------------------------------------------------------
// Note: V = (AO[s] | AS[s]) before the snoop result.

/*
static function void getActiveOwnerSharerVectorForSnoopResult (
    input  bit RV,
    input  bit RS,
    input  bit [SYS_nSysAIUs-1:0] A,      // one-hot vector Snooping AIU
    output bit [SYS_nSysAIUs-1:0] AOV,    // one-hot vector Active Owner Vector
    output bit [SYS_nSysAIUs-1:0] ASV,    // one-hot vector Active Sharer Vector
    output bit                         change
);
  change = 0;
  case ({RV, RS}) 
    2'b00, 2'b01 : begin AOV = &(~A); ASV = &(~A); change = 1; end
    2'b11        : begin AOV = &(~A); ASV = |A;    change = 1; end
  endcase
endfunction : getActiveOwnerSharerVectorForSnoopResult
*/
// ------------------------------------------------------------------
// CMDreq                |      
// Message      TR=DO/DS | AO[r]  AS[r]  Notes  
// ------------------------------------------------------------------
// CmdRdCpy       0   1  |  0      V    Remove from owner and add to sharer vector if valid
//                1   0  |  V      0    Add to owner vector if valid and remove from sharer
// ------------------------------------------------------------------
// CmdRdCln       0   1  |  0      1    Remove from owner and add to sharer vector (allocate)
//                1   0  |  1      0    Add to owner vector and remove from sharer (allocate)
// ------------------------------------------------------------------
// CmdRdVld       0   1  |  0      1    Remove from owner and add to sharer vector (allocate)
//                1   0  |  1      0    Add to owner vector and remove from sharer (allocate)
// ------------------------------------------------------------------
// CmdRdUnq       1   0  |  1      0    Add to owner vector and remove from sharer (allocate)
// ------------------------------------------------------------------
// CmdClnUnq      1   0  |  1      0    Add to owner vector and remove from sharer (allocate)
// ------------------------------------------------------------------
// CmdClnVld      0   1  |  0      V    Remove from owner and add to sharer vector if valid
//                1   0  |  V      0    Add to owner vector if valid and remove from sharer
// ------------------------------------------------------------------
// CmdClnInv      0   0  |  0      0    Remove from owner vector and from sharer vector
// ------------------------------------------------------------------
// CmdWrUnqPtl    0   0  |  0      0    Remove from owner vector and from sharer vector
//                0   1  |  0      V    Remove from owner and add to sharer vector if valid
// ------------------------------------------------------------------
// CmdWrUnqFull   0   0  |  0      0    Remove from owner vector and from sharer vector
//                0   1  |  0      V    Remove from owner and add to sharer vector if valid
// ------------------------------------------------------------------
// Table 71:  Active Owner and Sharer Vector Transitions for the Initiating Agent
// ------------------------------------------------------------------



// ------------------------------------------------------------------
// UPDreq                |      
// Message      TR=DO/DS | AO[r] AS[r]  Notes  
// ------------------------------------------------------------------
// UpdInv         ----   |  0      0    Remove from owner vector and from sharer vector
// ------------------------------------------------------------------
// Table 72:  Active Owner and Sharer Vector Transitions for the Initiating Agent


/*
static function bit getActiveOwnerSharerVectorForTransResult (
    input eMsgCMD cmd,
    input DO,
    input DS,
    input  bit [SYS_nSysAIUs-1:0] A,      // one-hot vector Requesting AIU
    input  bit [SYS_nSysAIUs-1:0] V,      // one-hot vector V = AOVi | ASVi
    output bit [SYS_nSysAIUs-1:0] AOVo,   // one-hot vector Active Owner Vector
    output bit [SYS_nSysAIUs-1:0] ASVo,   // one-hot vector Active Sharer Vector
    output bit                         change
);
  bit valid;
  valid = 0;
  case (cmd)
    eCmdRdCpy     : begin
                      case ({DO, DS}) 
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A&V); change = 1; valid = 1; end
                        2'b10 : begin AOVo = |(A&V); ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdRdCln     : begin
                      case ({DO, DS}) 
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A);   change = 1; valid = 1; end
                        2'b10 : begin AOVo = |(A);   ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdRdVld     : begin
                      case ({DO, DS}) 
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A);   change = 1; valid = 1; end
                        2'b10 : begin AOVo = |(A);   ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdRdUnq     : begin
                      case ({DO, DS}) 
                        2'b10 : begin AOVo = |(A);   ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdClnUnq    : begin
                      case ({DO, DS}) 
                        2'b10 : begin AOVo = |(A);   ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdClnVld    : begin
                      case ({DO, DS}) 
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A&V); change = 1; valid = 1; end
                        2'b10 : begin AOVo = |(A&V); ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdClnInv    : begin
                      case ({DO, DS}) 
                        2'b00 : begin AOVo = &(~A);  ASVo = &(~A);  change = 1; valid = 1; end
                      endcase
                    end
    eCmdWrUnqPtl  : begin
                      case ({DO, DS}) 
                        2'b00 : begin AOVo = &(~A);  ASVo = &(~A);  change = 1; valid = 1; end
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A&V); change = 1; valid = 1; end
                      endcase
                    end
    eCmdWrUnqFull : begin
                      case ({DO, DS}) 
                        2'b00 : begin AOVo = &(~A);  ASVo = &(~A);  change = 1; valid = 1; end
                        2'b01 : begin AOVo = &(~A);  ASVo = |(A&V); change = 1; valid = 1; end
                      endcase
                    end
    eCmdDvmMsg    : begin
                      valid = 0;
                    end
  endcase
  return valid;
endfunction : getActiveOwnerSharerVectorForTransResult
*/

// ------------------------------------------------------------------
//               Owner      Sharer   Sharer
// CMDreq        SNPreq     SNPreq   SNPreq        Notes
// Message       Message    Message  Message     
//                          (true)   (uncertain)
// ------------------------------------------------------------------
// CmdRdCpy      SnpClnDtr  ---      SnpClnDtw     Retrieve copy from owner
// CmdRdCln      SnpClnDtr  ---      SnpClnDtw     Retrieve copy from owner
// CmdRdVld      SnpVldDtr  ---      SnpClnDtw     Retrieve copy from owner
// CmdRdUnq      SnpInvDtr  SnpInv   SnpInv        Retrieve copy from owner and invalidate sharers
// CmdClnUnq     SnpInvDtw  SnpInv   SnpInv        Update memory from owner and invalidate sharers
// CmdClnVld     SnpClnDtw  ---      SnpClnDtw     Update memory from owner
// CmdClnInv     SnpInvDtw  SnpInv   SnpInv        Update memory from owner and invalidate sharers
// CmdWrUnqPtl   SnpInvDtw  SnpInv   SnpInv        Update memory from owner and invalidate sharers
// CmdWrUnqFull  SnpInv     SnpInv   SnpInv        Invalidate owner and sharers
// ------------------------------------------------------------------
// Table 69: CMDreq Message to SNPreq Message Mapping

//
// function mapOwnerSNPreq
//
static function bit mapOwnerSNPreq (input eMsgCMD cmd, output eMsgSNP snp);
  bit valid;
  valid = 0;
  case (cmd)
    //eCmdRdCpy     : begin valid = 1; snp = eSnpClnDtr; end
    eCmdRdCln     : begin valid = 1; snp = eSnpClnDtr; end
    eCmdRdVld     : begin valid = 1; snp = eSnpVldDtr; end
    eCmdRdUnq     : begin valid = 1; snp = eSnpInvDtr; end
    eCmdClnUnq    : begin valid = 1; snp = eSnpInvDtw; end
    eCmdClnVld    : begin valid = 1; snp = eSnpClnDtw; end
    eCmdClnInv    : begin valid = 1; snp = eSnpInvDtw; end
    eCmdWrUnqPtl  : begin valid = 1; snp = eSnpInvDtw; end
    eCmdWrUnqFull : begin valid = 1; snp = eSnpInv;    end
  endcase
  return valid;
endfunction : mapOwnerSNPreq

//
// function mapSharerSNPreq
//
static function bit mapSharerSNPreq (input eMsgCMD cmd, output eMsgSNP snp);
  bit valid;
  valid = 0;
  case (cmd)
    //eCmdRdCpy     : begin valid = 0;                end
    eCmdRdCln     : begin valid = 0;                end
    eCmdRdVld     : begin valid = 0;                end
    eCmdRdUnq     : begin valid = 1; snp = eSnpInv; end
    eCmdClnUnq    : begin valid = 1; snp = eSnpInv; end
    eCmdClnVld    : begin valid = 0;                end
    eCmdClnInv    : begin valid = 1; snp = eSnpInv; end
    eCmdWrUnqPtl  : begin valid = 1; snp = eSnpInv; end
    eCmdWrUnqFull : begin valid = 1; snp = eSnpInv; end
  endcase
  return valid;
endfunction : mapSharerSNPreq

//
// function mapSharerSNPreqUncertain
//
static function bit mapSharerSNPreqUncertain (input eMsgCMD cmd, output eMsgSNP snp);
  bit valid;
  valid = 0;
  case (cmd)
    //eCmdRdCpy     : begin valid = 1; snp = eSnpClnDtw; end
    eCmdRdCln     : begin valid = 1; snp = eSnpClnDtw; end
    eCmdRdVld     : begin valid = 1; snp = eSnpClnDtw; end
    eCmdRdUnq     : begin valid = 1; snp = eSnpInv;    end
    eCmdClnUnq    : begin valid = 1; snp = eSnpInv;    end
    eCmdClnVld    : begin valid = 1; snp = eSnpClnDtw; end
    eCmdClnInv    : begin valid = 1; snp = eSnpInv;    end
    eCmdWrUnqPtl  : begin valid = 1; snp = eSnpInv;    end
    eCmdWrUnqFull : begin valid = 1; snp = eSnpInv;    end
  endcase
  return valid;
endfunction : mapSharerSNPreqUncertain

//
// function genCMDreqs
//
/*
static function void genCMDreqs (cacheState_t state, output eMsgCMD msg[]);
  case (state)
    IX : msg = Concerto_CMDreq_List_In_IX; 
    SC : msg = Concerto_CMDreq_List_In_SC; 
    OC : msg = Concerto_CMDreq_List_In_OC; 
    OD : msg = Concerto_CMDreq_List_In_OD; 
    UC : msg = Concerto_CMDreq_List_In_UC; 
    UD : msg = Concerto_CMDreq_List_In_UD; 
  endcase
endfunction : genCMDreqs
*/
//
// function mapSnoopResultToSNPrsp
//
/*
static function bit mapSnoopResultToSNPrsp (eMsgSNP        msg,
                                            snoopResult_t  snoop_result,
                                     output snoopResult_t  snp_rsp_msg,
                                     output bit            is_dtr_data,
                                     output bit            is_dtw_data);
  bit valid;

  valid = 0;

  is_dtr_data = 0;
  is_dtw_data = 0;

  case (msg)

// ------------------------------------------------------------------
// Snoop   SNPrsp   DTRreq
// Result  Message  Message  Notes
// ------------------------------------------------------------------
// 0000    0000     ---      Invalidate sharer (or already invalid) (*)
// 0001    0001     DtrData  Invalidate sharer; provide data
// 0100    0100     ---      Invalidate owner
// 0101    0101     DtrData  Invalidate owner; provide data
// 0111    0111     DtrData  Invalidate owner; provide data
// 1000    1000     ---      No change to owner/sharer (*)
// 1001    1001     DtrData  No change to owner/sharer; provide data (*)
// 1011    N/A      N/A      Illegal response
// 1100    1100     ---      Owner to sharer
// 1101    1101     DtrData  Owner to sharer; provide data (*)
// 1111    1111     DtrData  Owner to sharer; provide data (* for SnpVldDtr)
// ------------------------------------------------------------------
// Table 32:  SnpClnDtr/SnpVldDtr Protocol Snoop Results
// ------------------------------------------------------------------

    eSnpClnDtr, eSnpVldDtr :
      begin
        case (snoop_result)
          4'b0000 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0001 : begin valid = 1; snp_rsp_msg = 4'b0001; is_dtr_data = 1; end
          4'b0011 : begin valid = 1; snp_rsp_msg = 4'b0011; is_dtr_data = 1; end
          4'b1000 : begin valid = 0;                                         end
          4'b1001 : begin valid = 1; snp_rsp_msg = 4'b1001; is_dtr_data = 1; end
          4'b1011 : begin valid = 0;                                         end
          4'b1100 : begin valid = 1; snp_rsp_msg = 4'b1100;                  end
          4'b1101 : begin valid = 1; snp_rsp_msg = 4'b1101; is_dtr_data = 1; end
          4'b1111 : begin valid = 1; snp_rsp_msg = 4'b1111; is_dtr_data = 1; end
        endcase
      end

// ------------------------------------------------------------------
// Snoop   SNPrsp   DTRreq
// Result  Message  Message  Notes
// ------------------------------------------------------------------
// 0000    0000     ---      Invalidate sharer (or already invalid) (*)
// 0001    0001     DtrData  Invalidate sharer; provide data (*)
// 0100    0100     ---      Invalidate owner
// 0101    0101     DtrData  Invalidate owner; provide data (*)
// 0111    0111     DtrData  Invalidate owner; provide data (*)
// 1xxx    N/A      N/A      Illegal response
// ------------------------------------------------------------------
// Table 33:  SnpInvDtr Protocol Snoop Results
// ------------------------------------------------------------------

    eSnpInvDtr :
      begin
        case (snoop_result)
          4'b0000 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0001 : begin valid = 1; snp_rsp_msg = 4'b0001; is_dtr_data = 1; end
          4'b0011 : begin valid = 1; snp_rsp_msg = 4'b0011; is_dtr_data = 1; end
        endcase
      end

// ------------------------------------------------------------------
// Snoop   SNPrsp   DTRreq
// Result  Message  Message      Notes
// ------------------------------------------------------------------
// 0000    0000     ---          Invalidate sharer (or already invalid) (*)
// 0001    0000     ---          Invalidate sharer; drop data
// 0100    0100     ---          Invalidate owner
// 0101    0100     ---          Invalidate owner; drop data
// 0111    0100     DtwData      Invalidate owner; update memory
// 1000    1000     ---          No change to owner/sharer (*)
// 1001    1000     ---          No change to owner/sharer; drop data
// 1011    1000     DtwData      No change to owner; update memory (*)
// 1100    1100     ---          Owner to sharer
// 1101    1100     ---          Owner to sharer; drop data
// 1111    1100     DtwData      Owner to sharer; update memory
// ------------------------------------------------------------------
// Table 34:  SnpClnDtw Protocol Snoop Results
// ------------------------------------------------------------------

    eSnpClnDtw :
      begin
        case (snoop_result)
          4'b0000 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0001 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0011 : begin valid = 1; snp_rsp_msg = 4'b0000; is_dtw_data = 1; end
          4'b1000 : begin valid = 1; snp_rsp_msg = 4'b1000;                  end
          4'b1001 : begin valid = 1; snp_rsp_msg = 4'b1000;                  end
          4'b1011 : begin valid = 1; snp_rsp_msg = 4'b1000; is_dtw_data = 1; end
          4'b1100 : begin valid = 1; snp_rsp_msg = 4'b1100;                  end
          4'b1101 : begin valid = 1; snp_rsp_msg = 4'b1100;                  end
          4'b1111 : begin valid = 1; snp_rsp_msg = 4'b1100; is_dtw_data = 1; end
        endcase
      end

// ------------------------------------------------------------------
// Snoop   SNPrsp   DTRreq
// Result  Message  Message      Notes
// ------------------------------------------------------------------
// 0000    0000     ---          Invalidate sharer (or already invalid) (*)
// 0001    0000     ---          Invalidate sharer; drop data
// 0100    0100     ---          Invalidate owner (*)
// 0101    0100     ---          Invalidate owner; drop data
// 0111    0100     DtwData      Invalidate owner; update memory (*)
// 1xxx    N/A      N/A          Illegal response
// ------------------------------------------------------------------
// Table 35:  SnpInvDtw/SnpRecall Protocol Snoop Results
// ------------------------------------------------------------------

    eSnpInvDtw, eSnpRecall :
      begin
        case (snoop_result)
          4'b0000 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0001 : begin valid = 1; snp_rsp_msg = 4'b0000;                  end
          4'b0011 : begin valid = 1; snp_rsp_msg = 4'b0000; is_dtw_data = 1; end
        endcase
      end

// ------------------------------------------------------------------
// Snoop   SNPrsp   DTRreq
// Result  Message  Message      Notes
// ------------------------------------------------------------------
// 0000    0000     ---          Invalidate sharer (or already invalid) (*)
// 0001    0000     ---          Invalidate sharer; drop data
// 0100    0100     ---          Invalidate owner (*)
// 0101    0100     ---          Invalidate owner; drop data
// 0111    0100     ---          Invalidate owner; drop data
// 1xxx    N/A      N/A          Illegal response
// ------------------------------------------------------------------
// Table 36:  SnpInv Protocol Snoop Results
// ------------------------------------------------------------------

    eSnpInv    :
      begin
        case (snoop_result)
          4'b0000 : begin valid = 1; snp_rsp_msg = 4'b0000; end
          4'b0001 : begin valid = 1; snp_rsp_msg = 4'b0000; end
          4'b0011 : begin valid = 1; snp_rsp_msg = 4'b0000; end
        endcase
      end

  endcase

  return valid;

endfunction : mapSnoopResultToSNPrsp
*/
// ------------------------------------------------------------------
// RV  RS  DC  DT  Legal?  Notes
// ------------------------------------------------------------------
// 0   0   0   0   Yes     Copy is now IX from non-owned (IX|SC) state
// 0   0   0   1   Yes     Copy is now IX from non-owned (SC) state; clean data transfer
// 0   0   1   0   No      Cannot downgrade to clean from non-owned state
// 0   0   1   1   No      Cannot downgrade to clean from non-owned state
// 0   1   0   0   Yes     Copy is now IX from owned (OC|UC) state
// 0   1   0   1   Yes     Copy is now IX from owned (OC|UC) state; clean data transfer
// 0   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 0   1   1   1   Yes     Copy is now IX from owned (OD|UD) state; dirty data transfer
// 1   0   0   0   Yes     Copy is clean (SC|OC|UC); no owner/sharer change
// 1   0   0   1   Yes     Copy is valid; no owner/sharer change; clean data transfer
// 1   0   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   0   1   1   Yes     Copy is owned (OC|UC); no owner change; dirty data transfer
// 1   1   0   0   Yes     Copy is now SC from owned (OC|UC) state
// 1   1   0   1   Yes     Copy is now SC from owned (OC|UC) state; clean data transfer
// 1   1   1   0   No      Cannot downgrade to clean without dirty data transfer
// 1   1   1   1   Yes     Copy is now SC from owned (OD|UD) state; dirty data transfer
// ------------------------------------------------------------------
// Table 7: Legal Protocol Snoop Results
// ------------------------------------------------------------------

//
// function genSnoopResults
//
static function void genSnoopResults (cacheState_t   start_state,
                               eMsgSNP        msg,
                        output snoopResult_t  snoop_result [$],
                        output cacheState_t   ending_state [$]);

  cacheState_t  end_state;
  snoopResult_t result;
  snoopResult_t result_tmp;
  int           qx [$];
  int           qy [$];
  bit           is_dtr_data;
  bit           is_dtw_data;

  snoop_result.delete();
  ending_state.delete();

  foreach (Concerto_cacheState_List [i]) begin
    end_state = Concerto_cacheState_List[i];

    foreach (Concerto_LegalSnoopResult_List[i]) begin
      result_tmp = Concerto_LegalSnoopResult_List[i]; // type conversion 
      if (isLegalSnoopStateTransition (msg, 
                                       result_tmp.RV,
                                       result_tmp.RS,
                                       result_tmp.DC,
                                       result_tmp.DT,
                                       start_state,
                                       end_state)) begin
      if (mapSnoopResultToSNPrsp (msg, Concerto_LegalSnoopResult_List[i], result, is_dtr_data, is_dtw_data))
      begin
        qx = ending_state.find_first_index() with ( item == end_state);
        qy = snoop_result.find_first_index() with ( item == result);
        if (qx.size() && qy.size() && (qx[0] == qy[0])) begin
          // duplicate is found, don't push it to output list
        end else begin
          snoop_result.push_back(result);
          ending_state.push_back(end_state);
        end
      end

      end // if
    end // foreach
  end // foreach

endfunction : genSnoopResults

//
// function genSnoopResultsStates
//
static function void genSnoopResultsStates (cacheState_t   start_state,
                                     eMsgSNP        msg,
                                     snoopResult_t  snoop_result,
                              output cacheState_t   ending_state [$]);

  cacheState_t  end_state;
  snoopResult_t result;
  int           qx [$];
  bit           is_dtr_data;
  bit           is_dtw_data;

  ending_state.delete();

  foreach (Concerto_cacheState_List [i]) begin
    end_state = Concerto_cacheState_List[i];

    if (isLegalSnoopStateTransition (msg, 
                                     snoop_result.RV,
                                     snoop_result.RS,
                                     snoop_result.DC,
                                     snoop_result.DT,
                                     start_state,
                                     end_state)) begin
      if (mapSnoopResultToSNPrsp (msg, snoop_result, result, is_dtr_data, is_dtw_data))
      begin
        qx = ending_state.find_first_index() with ( item == end_state);
        if (qx.size()) begin
          // duplicate is found, don't push it to output list
        end else begin
          ending_state.push_back(end_state);
        end
      end

    end // if
  end // foreach

endfunction : genSnoopResultsStates
//
// function genTransResults
//
static function void genTransResults (
                        input  eMsgCMD       msg,
                        output coherResult_t coher_result [$],
                        output transResult_t trans_result [$],
                        output cacheState_t  ending_state [$],
                        input  cacheState_t  initial_state );

  cacheState_t  end_state;
  transResult_t result;
  coherResult_t coher;
  bit           isReqAIUToUpdateMem;
  int           qx [$];
  int           qy [$];
  bit           is_dtw_data;
  bit           is_dtw_none;

  coher_result.delete();
  trans_result.delete();
  ending_state.delete();

  foreach (Concerto_cacheState_List [i]) begin
    end_state = Concerto_cacheState_List[i];

    for (int s = 4'b0000; s <= 4'b1111; s++) begin
      coher.SS = s[3];
      coher.SO = s[2];
      coher.SD = s[1];
      coher.ST = s[0] ? $urandom_range((2**$bits(coher.ST))-1, 1) : 0;
      if (isLegalSTRreqEndingState ( coher,
                                     end_state,
                                     isReqAIUToUpdateMem )) begin
        for (int d = 2'b00; d < 2'b11; d++) begin //NOTE: TR={DO,DS}=2'b11 is reserved.
          result.DO = d[1];
          result.DS = d[0];
          if (isLegalSTRreqResultForCmd ( msg,
                                          coher,
                                          end_state,
                                          result,
                                          initial_state,
                                          is_dtw_data,
                                          is_dtw_none )) 
          begin
             qx = ending_state.find_first_index() with ( item == end_state);
/*
             qy = trans_result.find_first_index() with ( item == result);
             if (qx.size() && qy.size() && (qx[0] == qy[0])) begin
*/
             qy = trans_result.find_first_index() with ( item == trans_result[qx[0]]);
             if (qx.size() && qy.size()) begin
               // duplicate is found, don't push it to output list
             end else begin
               if (msg == eCmdClnVld) begin
                 if ((~result.DO & result.DS) | (result.DO & ~result.DS)) begin
                   coher_result.push_back(coher);
                   trans_result.push_back(result);
                   ending_state.push_back(end_state);
                 end
               end else if (isLegalSTRrspInstalledState(result.DO, result.DS, end_state)) begin
                 coher_result.push_back(coher);
                 trans_result.push_back(result);
                 ending_state.push_back(end_state);
               end
             end
          end
        end // for d
      end // if
    end // for s

  end // foreach 

endfunction : genTransResults

//
// function genTransResultsTrans
//
static function void genTransResultsTrans (
                             input  eMsgCMD       msg,
                             input  coherResult_t coher,
                             output transResult_t trans_result [$],
                             output cacheState_t  ending_state [$],
                             input  cacheState_t  initial_state );

  cacheState_t  end_state;
  transResult_t result;
  bit           isReqAIUToUpdateMem;
  int           qx [$];
  int           qy [$];
  bit           is_dtw_data;
  bit           is_dtw_none;

  trans_result.delete();
  ending_state.delete();

  foreach (Concerto_cacheState_List [i]) begin
    end_state = Concerto_cacheState_List[i];

      if (isLegalSTRreqEndingState ( coher,
                                     end_state,
                                     isReqAIUToUpdateMem )) begin
        for (int d = 2'b00; d < 2'b11; d++) begin //NOTE: TR={DO,DS}=2'b11 is reserved.
          result.DO = d[1];
          result.DS = d[0];
          if (isLegalSTRreqResultForCmd ( msg,
                                          coher,
                                          end_state,
                                          result,
                                          initial_state, 
                                          is_dtw_data,
                                          is_dtw_none )) 
          begin

            // $display("NAN: msg:%s SS:%b SO:%b SD:%b ST:%0d end_state:%s DO:%b DS:%b initial_state:%s",
            //     msg.name(), coher.SS, coher.SO, coher.SD, coher.ST, end_state.name(), result.DO,
            //     result.DS, initial_state.name());
             qx = ending_state.find_first_index() with ( item == end_state);
             qy = trans_result.find_first_index() with ( item == result);
             if (qx.size() && qy.size() && (qx[0] == qy[0])) begin
               // duplicate is found, don't push it to output list
             end else begin
               if (msg == eCmdClnVld) begin
                 if ((~result.DO & result.DS) | (result.DO & ~result.DS)) begin
                   trans_result.push_back(result);
                   ending_state.push_back(end_state);
                 end
               end else if (isLegalSTRrspInstalledState(result.DO, result.DS, end_state)) begin
                 trans_result.push_back(result);
                 ending_state.push_back(end_state);
               end
             end
          end
        end // for d
      end // if

  end // foreach 

endfunction : genTransResultsTrans

//
// function genTransResultsStates
//
static function void genTransResultsStates (
                              input  eMsgCMD       msg,
                              input  coherResult_t coher,
                              input  transResult_t trans,
                              output cacheState_t  ending_state [$],
                              input  cacheState_t  initial_state = IX );

  cacheState_t  end_state;
  bit           isReqAIUToUpdateMem;
  int           qx [$];
  bit           is_dtw_data;
  bit           is_dtw_none;

  ending_state.delete();

  foreach (Concerto_cacheState_List [i]) begin
    end_state = Concerto_cacheState_List[i];

      if (isLegalSTRreqEndingState ( coher,
                                     end_state,
                                     isReqAIUToUpdateMem )) begin
          if (isLegalSTRreqResultForCmd ( msg,
                                          coher,
                                          end_state,
                                          trans,
                                          initial_state, 
                                          is_dtw_data,
                                          is_dtw_none )) 
          begin
             qx = ending_state.find_first_index() with ( item == end_state);
             if (qx.size()) begin
               // duplicate is found, don't push it to output list
             end else begin
               if (msg == eCmdClnVld) begin
                 if ((~trans.DO & trans.DS) | (trans.DO & ~trans.DS)) begin
                   ending_state.push_back(end_state);
                 end
               end else if (isLegalSTRrspInstalledState(trans.DO, trans.DS, end_state)) begin
                 ending_state.push_back(end_state);
               end
             end
          end
      end // if

  end // foreach 

endfunction : genTransResultsStates

////////////////////////////////////////////////////////////////////////////////

static function void genLegalStates (output cacheState_t statesList [$] [SYS_nSysAIUs]);

  cacheState_t   states [SYS_nSysAIUs];
  int            count  [SYS_nSysAIUs];
  int  total;

  total = 1;
  for (int i=0; i < SYS_nSysAIUs; i++) begin
    total = total * Concerto_cacheState_List.size;
    count[i] = total;
  end

  for (int i=0; i < total; i++) begin
    for (int c=0; c < SYS_nSysAIUs; c++) begin
      states[c] = Concerto_cacheState_List[(i / (count[c] / Concerto_cacheState_List.size)) % Concerto_cacheState_List.size];
    end
    if (isLegalCacheStates (states)) begin
      statesList.push_back(states);
    end
  end

endfunction : genLegalStates

////////////////////////////////////////////////////////////////////////////////

static function void genCombStates(cacheState_t in_states [SYS_nSysAIUs][$], output cacheState_t out_states [][SYS_nSysAIUs]);

  cacheState_t   states [SYS_nSysAIUs];
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

endfunction : genCombStates

////////////////////////////////////////////////////////////////////////////////

static function void genCombSnoopResults(snoopResult_t in_states [SYS_nSysAIUs][$], output snoopResult_t out_states [][SYS_nSysAIUs]);

  snoopResult_t  states [SYS_nSysAIUs];
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

endfunction : genCombSnoopResults

////////////////////////////////////////////////////////////////////////////////

static function void genCoherResultsFromSnoops(snoopResult_t snoop_results [][SYS_nSysAIUs], output coherResult_t coher_results []);

  coherResult_t coher_result;

  coher_results = new[snoop_results.size()];

  for (int n = 0; n < snoop_results.size(); n++) begin
    coher_result.SS = 0;
    coher_result.SO = 0;
    coher_result.SD = 0;
    coher_result.ST = 0;

    for (int i = 0; i < SYS_nSysAIUs; i++) begin
      coher_result.SS = coher_result.SS | snoop_results[n][i].RV;
      coher_result.SO = coher_result.SO | snoop_results[n][i].RS;
      coher_result.SD = coher_result.SD | snoop_results[n][i].DC;
      coher_result.ST = coher_result.ST + snoop_results[n][i].DT;
    end

    coher_results[n] = coher_result;
  end

endfunction : genCoherResultsFromSnoops

////////////////////////////////////////////////////////////////////////////////

static function void genStatesFromReqAIUEndingStates(cacheState_t initial_states [SYS_nSysAIUs],
                                                     AIUID_t      req_aiu_id,
                                                     cacheState_t req_aiu_ending_states [],
                                              output cacheState_t ending_states  [][SYS_nSysAIUs]);

  ending_states = new[req_aiu_ending_states.size()];

  for (int i=0; i < req_aiu_ending_states.size(); i++) begin
    ending_states[i] = initial_states;
    ending_states[i][req_aiu_id] = req_aiu_ending_states[i];
  end

endfunction : genStatesFromReqAIUEndingStates

////////////////////////////////////////////////////////////////////////////////

//static function bit isCMDreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isCMDreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    CMD_RD_CPY, CMD_RD_CLN, CMD_RD_VLD, CMD_RD_UNQ, CMD_CLN_UNQ, CMD_CLN_VLD, CMD_CLN_INV,
//    CMD_WR_UNQ_PTL, CMD_WR_UNQ_FULL, CMD_DVM_MSG:
//      isCMDreq = 1;
//    default:
//      isCMDreq = 0;
//  endcase
//
//  return isCMDreq;
//endfunction : isCMDreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isUPDreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isUPDreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    UPD_INV:
//      isUPDreq = 1;
//    default:
//      isUPDreq = 0;
//  endcase
//
//  return isUPDreq;
//endfunction : isUPDreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isSNPreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isSNPreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    SNP_CLN_DTR, SNP_VLD_DTR, SNP_INV_DTR, SNP_INV_DTW, SNP_RECALL, SNP_CLN_DTW, SNP_INV, SNP_DVM_MSG:
//      isSNPreq = 1;
//    default:
//      isSNPreq = 0;
//  endcase
//
//  return isSNPreq;
//endfunction : isSNPreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isHNTreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isHNTreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    HNT_READ :
//      isHNTreq = 1;
//    default:
//      isHNTreq = 0;
//  endcase
//
//  return isHNTreq;
//endfunction : isHNTreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isMRDreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isMRDreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    MRD_RD_CLN, MRD_RD_FLSH, MRD_RD_VLD, MRD_RD_INV, MRD_FLUSH:
//      isMRDreq = 1;
//    default:
//      isMRDreq = 0;
//  endcase
//
//  return isMRDreq;
//endfunction : isMRDreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isSTRreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isSTRreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    STR_STATE :
//      isSTRreq = 1;
//    STR_DVM_CMP :
//      isSTRreq = 1;
//    default:
//      isSTRreq = 0;
//  endcase
//
//  return isSTRreq;
//endfunction : isSTRreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isDTRreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isDTRreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    DTR_DATA_CLN, DTR_DATA_DTY, DTR_SYS_VIS, DTR_DVM_CMP :
//      isDTRreq = 1;
//    default:
//      isDTRreq = 0;
//  endcase
//
//  return isDTRreq;
//endfunction : isDTRreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit isDTWreqFromSfi (sfi_req_packet_t req_pkt);
//  MsgType_t      msg_type;
//  bit            isDTWreq;
//
//  msg_type = req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB];
//  case (msg_type)
//    DTW_DATA_PTL, DTW_DATA_DTY, DTW_DATA_CLN :
//      isDTWreq = 1;
//    default:
//      isDTWreq = 0;
//  endcase
//
//  return isDTWreq;
//endfunction : isDTWreqFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function bit compareSfiPriv (sfi_reqPriv_t a, sfi_reqPriv_t b);
//
//   return (a[WREQSFIPRIV-1:SFI_PRIV_MSG_TYPE_MSB+1] == b[WREQSFIPRIV-1:SFI_PRIV_MSG_TYPE_MSB+1]);
//
//endfunction : compareSfiPriv
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function UPDreqEntry_t getUPDreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  UPDreqEntry_t upd_req_entry;
//
//  upd_req_entry.cache_addr        = req_pkt.req_addr;
//  upd_req_entry.home_dce_unit_id  = req_pkt.req_sfiSlvId;
//  upd_req_entry.upd_sfi_trans_id  = req_pkt.req_transId;
//  upd_req_entry.upd_msg_type      = eMsgUPD'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  upd_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  upd_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  upd_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  upd_req_entry.req_aiu_proc_id   = (SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_PROCID_MSB:SFI_PRIV_REQ_AIU_PROCID_LSB] : 0;
//  upd_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  upd_req_entry.req_security      = req_pkt.req_security;
//  upd_req_entry.req_urgency       = req_pkt.req_urgency;
//  upd_req_entry.req_press         = req_pkt.req_press;
//  upd_req_entry.req_hurry         = req_pkt.req_hurry;
//
//  return upd_req_entry;
//endfunction : getUPDreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function CMDreqEntry_t getCMDreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  CMDreqEntry_t cmd_req_entry;
//
//  cmd_req_entry.cache_addr        = req_pkt.req_addr;
//  cmd_req_entry.home_dce_unit_id  = req_pkt.req_sfiSlvId;
//  cmd_req_entry.cmd_sfi_trans_id  = req_pkt.req_transId;
//  cmd_req_entry.cmd_msg_type      = eMsgCMD'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  cmd_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  cmd_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  cmd_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  cmd_req_entry.req_aiu_proc_id   = (SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_PROCID_MSB:SFI_PRIV_REQ_AIU_PROCID_LSB] : 0;
//  cmd_req_entry.ace_lock          = req_pkt.req_sfiPriv[SFI_PRIV_REQ_ACE_LOCK_MSB:SFI_PRIV_REQ_ACE_LOCK_LSB];
//  cmd_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  cmd_req_entry.req_security      = req_pkt.req_security;
//  cmd_req_entry.req_urgency       = req_pkt.req_urgency;
//  cmd_req_entry.req_press         = req_pkt.req_press;
//  cmd_req_entry.req_hurry         = req_pkt.req_hurry;
//  cmd_req_entry.data              = new[req_pkt.req_data.size()](req_pkt.req_data);
//  cmd_req_entry.be                = new[req_pkt.req_be.size()](req_pkt.req_be);
//
//  return cmd_req_entry;
//endfunction : getCMDreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function SNPreqEntry_t getSNPreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  SNPreqEntry_t snp_req_entry;
//
//  snp_req_entry.cache_addr        = req_pkt.req_addr;
//  snp_req_entry.snp_aiu_unit_id   = req_pkt.req_sfiSlvId;
//  snp_req_entry.snp_sfi_trans_id  = req_pkt.req_transId;
//  snp_req_entry.snp_msg_type      = eMsgSNP'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  snp_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  snp_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  snp_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  snp_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  snp_req_entry.req_security      = req_pkt.req_security;
//  snp_req_entry.req_urgency       = req_pkt.req_urgency;
//  snp_req_entry.req_press         = req_pkt.req_press;
//  snp_req_entry.req_hurry         = req_pkt.req_hurry;
//  snp_req_entry.data              = new[req_pkt.req_data.size()](req_pkt.req_data);
//  snp_req_entry.be                = new[req_pkt.req_be.size()](req_pkt.req_be);
//
//  return snp_req_entry;
//endfunction : getSNPreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function MRDreqEntry_t getMRDreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  MRDreqEntry_t mrd_req_entry;
//
//  mrd_req_entry.cache_addr        = req_pkt.req_addr;
//  mrd_req_entry.home_dmi_unit_id  = req_pkt.req_sfiSlvId;
//  mrd_req_entry.mrd_sfi_trans_id  = req_pkt.req_transId;
//  mrd_req_entry.mrd_msg_type      = eMsgMRD'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  mrd_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  mrd_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  mrd_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  mrd_req_entry.req_aiu_proc_id   = (SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_PROCID_MSB:SFI_PRIV_REQ_AIU_PROCID_LSB] : 0;
//  mrd_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  mrd_req_entry.req_security      = req_pkt.req_security;
//  mrd_req_entry.req_urgency       = req_pkt.req_urgency;
//  mrd_req_entry.req_press         = req_pkt.req_press;
//  mrd_req_entry.req_hurry         = req_pkt.req_hurry;
//
//  return mrd_req_entry;
//endfunction : getMRDreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function HNTreqEntry_t getHNTreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  HNTreqEntry_t hnt_req_entry;
//
//  hnt_req_entry.cache_addr        = req_pkt.req_addr;
//  hnt_req_entry.home_dmi_unit_id  = req_pkt.req_sfiSlvId;
//  hnt_req_entry.hnt_sfi_trans_id  = req_pkt.req_transId;
//  hnt_req_entry.hnt_msg_type      = eMsgHNT'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  hnt_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  hnt_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  hnt_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  hnt_req_entry.req_aiu_proc_id   = (SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_PROCID_MSB:SFI_PRIV_REQ_AIU_PROCID_LSB] : 0;
//  hnt_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  hnt_req_entry.req_security      = req_pkt.req_security;
//  hnt_req_entry.req_urgency       = req_pkt.req_urgency;
//  hnt_req_entry.req_press         = req_pkt.req_press;
//  hnt_req_entry.req_hurry         = req_pkt.req_hurry;
//
//  return hnt_req_entry;
//endfunction : getHNTreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function STRreqEntry_t getSTRreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  STRreqEntry_t str_req_entry;
//
//  str_req_entry.req_aiu_unit_id   = req_pkt.req_sfiSlvId;
//  str_req_entry.str_sfi_trans_id  = req_pkt.req_transId;
//  str_req_entry.str_msg_type      = eMsgSTR'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  str_req_entry.req_aiu_trans_id  = req_pkt.req_addr[SFI_ADDR_REQ_TRANS_ID_MSB:SFI_ADDR_REQ_TRANS_ID_LSB];
//  str_req_entry.req_aiu_id        = req_pkt.req_addr[SFI_ADDR_REQ_AIU_ID_MSB:SFI_ADDR_REQ_AIU_ID_LSB];
//  str_req_entry.err_result        = req_pkt.req_sfiPriv[SFI_PRIV_STR_ERR_RESULT_MSB:SFI_PRIV_STR_ERR_RESULT_LSB];
//  str_req_entry.coher_result      = req_pkt.req_sfiPriv[SFI_PRIV_COHER_RESULT_MSB:SFI_PRIV_COHER_RESULT_LSB];
//  str_req_entry.req_security      = req_pkt.req_security;
//  str_req_entry.ace_exokay        = req_pkt.req_sfiPriv[SFI_PRIV_STR_ACE_EXOKAY_MSB:SFI_PRIV_STR_ACE_EXOKAY_LSB];
//  str_req_entry.req_urgency       = req_pkt.req_urgency;
//  str_req_entry.req_press         = req_pkt.req_press;
//  str_req_entry.req_hurry         = req_pkt.req_hurry;
//
//  return str_req_entry;
//endfunction : getSTRreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function DTRreqEntry_t getDTRreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  DTRreqEntry_t dtr_req_entry;
//
//  dtr_req_entry.req_aiu_unit_id   = req_pkt.req_sfiSlvId;
//  dtr_req_entry.dtr_sfi_trans_id  = req_pkt.req_transId;
//  dtr_req_entry.dtr_msg_type      = eMsgDTR'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  dtr_req_entry.req_aiu_trans_id  = req_pkt.req_addr[SFI_ADDR_REQ_TRANS_ID_MSB:SFI_ADDR_REQ_TRANS_ID_LSB];
//  dtr_req_entry.req_aiu_id        = req_pkt.req_addr[SFI_ADDR_REQ_AIU_ID_MSB:SFI_ADDR_REQ_AIU_ID_LSB];
//  dtr_req_entry.err_result        = req_pkt.req_sfiPriv[SFI_PRIV_DTR_ERR_RESULT_MSB:SFI_PRIV_DTR_ERR_RESULT_LSB];
//  dtr_req_entry.req_security      = req_pkt.req_security;
//  dtr_req_entry.req_urgency       = req_pkt.req_urgency;
//  dtr_req_entry.req_press         = req_pkt.req_press;
//  dtr_req_entry.req_hurry         = req_pkt.req_hurry;
//  dtr_req_entry.req_length        = req_pkt.req_length;
//  dtr_req_entry.req_burst         = req_pkt.req_burst;
//  dtr_req_entry.data              = new [req_pkt.req_data.size()](req_pkt.req_data);
//  dtr_req_entry.be                = new [req_pkt.req_be.size()](req_pkt.req_be);
//  dtr_req_entry.dtr_offset        = req_pkt.req_sfiPriv[SFI_PRIV_OFFSET_MSB:SFI_PRIV_OFFSET_LSB];
//
//  return dtr_req_entry;
//endfunction : getDTRreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function DTWreqEntry_t getDTWreqEntryFromSfi (sfi_req_packet_t req_pkt);
//  DTWreqEntry_t dtw_req_entry;
//
//  dtw_req_entry.cache_addr        = req_pkt.req_addr;
//  dtw_req_entry.home_dmi_unit_id  = req_pkt.req_sfiSlvId;
//  dtw_req_entry.dtw_sfi_trans_id  = req_pkt.req_transId;
//  dtw_req_entry.dtw_msg_type      = eMsgDTW'(req_pkt.req_sfiPriv[SFI_PRIV_MSG_TYPE_MSB:SFI_PRIV_MSG_TYPE_LSB]);
//  dtw_req_entry.msg_attr          = req_pkt.req_sfiPriv[SFI_PRIV_MSG_ATTR_MSB:SFI_PRIV_MSG_ATTR_LSB];
//  dtw_req_entry.req_aiu_trans_id  = req_pkt.req_sfiPriv[SFI_PRIV_REQ_TRANS_ID_MSB:SFI_PRIV_REQ_TRANS_ID_LSB];
//  dtw_req_entry.req_aiu_id        = req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_ID_MSB:SFI_PRIV_REQ_AIU_ID_LSB];
//  dtw_req_entry.req_aiu_proc_id   = (SFI_PRIV_REQ_AIU_PROCID_MSB > 0) ? req_pkt.req_sfiPriv[SFI_PRIV_REQ_AIU_PROCID_MSB:SFI_PRIV_REQ_AIU_PROCID_LSB] : 0;
//  dtw_req_entry.req_sfiPriv       = req_pkt.req_sfiPriv;
//  dtw_req_entry.req_security      = req_pkt.req_security;
//  dtw_req_entry.req_urgency       = req_pkt.req_urgency;
//  dtw_req_entry.req_press         = req_pkt.req_press;
//  dtw_req_entry.req_hurry         = req_pkt.req_hurry;
//  dtw_req_entry.data              = new [req_pkt.req_data.size()](req_pkt.req_data);
//  dtw_req_entry.be                = new [req_pkt.req_be.size()](req_pkt.req_be);
//  dtw_req_entry.req_length        = req_pkt.req_length;
//  dtw_req_entry.req_burst         = req_pkt.req_burst;
//
//  return dtw_req_entry;
//endfunction : getDTWreqEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function UPDrspEntry_t getUPDrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  UPDrspEntry_t upd_rsp_entry;
//
//  upd_rsp_entry.upd_sfi_trans_id = rsp_pkt.rsp_transId;
//  upd_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  upd_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return upd_rsp_entry;
//endfunction : getUPDrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function CMDrspEntry_t getCMDrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  CMDrspEntry_t cmd_rsp_entry;
//
//  cmd_rsp_entry.cmd_sfi_trans_id = rsp_pkt.rsp_transId;
//  cmd_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  cmd_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return cmd_rsp_entry;
//endfunction : getCMDrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function SNPrspEntry_t getSNPrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  SNPrspEntry_t snp_rsp_entry;
//
//  snp_rsp_entry.snp_sfi_trans_id = rsp_pkt.rsp_transId;
//  snp_rsp_entry.snoop_result     = rsp_pkt.rsp_sfiPriv[SFI_PRIV_SNOOP_RESULT_MSB:SFI_PRIV_SNOOP_RESULT_LSB];
//  snp_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  snp_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return snp_rsp_entry;
//endfunction : getSNPrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function MRDrspEntry_t getMRDrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  MRDrspEntry_t mrd_rsp_entry;
//
//  mrd_rsp_entry.mrd_sfi_trans_id = rsp_pkt.rsp_transId;
//  mrd_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  mrd_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return mrd_rsp_entry;
//endfunction : getMRDrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function HNTrspEntry_t getHNTrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  HNTrspEntry_t hnt_rsp_entry;
//
//  hnt_rsp_entry.hnt_sfi_trans_id = rsp_pkt.rsp_transId;
//  hnt_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  hnt_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return hnt_rsp_entry;
//endfunction : getHNTrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function STRrspEntry_t getSTRrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  STRrspEntry_t str_rsp_entry;
//
//  str_rsp_entry.str_sfi_trans_id = rsp_pkt.rsp_transId;
//  str_rsp_entry.trans_result     = rsp_pkt.rsp_sfiPriv[SFI_PRIV_TRANS_RESULT_MSB:SFI_PRIV_TRANS_RESULT_LSB];
//  str_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  str_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return str_rsp_entry;
//endfunction : getSTRrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function DTRrspEntry_t getDTRrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  DTRrspEntry_t dtr_rsp_entry;
//
//  dtr_rsp_entry.dtr_sfi_trans_id = rsp_pkt.rsp_transId;
//  dtr_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  dtr_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return dtr_rsp_entry;
//endfunction : getDTRrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function DTWrspEntry_t getDTWrspEntryFromSfi (sfi_rsp_packet_t rsp_pkt);
//  DTWrspEntry_t dtw_rsp_entry;
//
//  dtw_rsp_entry.dtw_sfi_trans_id = rsp_pkt.rsp_transId;
//  dtw_rsp_entry.rsp_status = rsp_pkt.rsp_status;
//  dtw_rsp_entry.rsp_errCode = rsp_pkt.rsp_errCode;
//
//  return dtw_rsp_entry;
//endfunction : getDTWrspEntryFromSfi
//
//////////////////////////////////////////////////////////////////////////////////
//
//typedef bit [($size(cacheState_t)*SYS_nSysAIUs)-1:0] statesInBits_t;
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function void convertStatesToBits (cacheState_t states [SYS_nSysAIUs], output statesInBits_t result);
//
//  for (int c = 0; c < SYS_nSysAIUs; c++) begin
//    result[ (c*$size(cacheState_t)) +: $size(cacheState_t) ] = states[c];
//  end
//
//endfunction : convertStatesToBits
//
//////////////////////////////////////////////////////////////////////////////////
//
//static function void convertBitsToStates (statesInBits_t value, output cacheState_t states [SYS_nSysAIUs]);
//
//  for (int c = 0; c < SYS_nSysAIUs; c++) begin
//    states[c] = cacheState_t'(value[ (c*$size(cacheState_t)) +: $size(cacheState_t) ]);
//  end
//
//endfunction : convertBitsToStates
//
//////////////////////////////////////////////////////////////////////////////////
////
//// See Concerto DCE Architecture Spec, Table 8: DCE Master TransID Encoding
//// Note: DCE Master Interface connects to SFI Slave Interface
//////////////////////////////////////////////////////////////////////////////////
//
//static function sfi_transId_t getDceMasterTransIdForSNP (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-2] = 2'b00;
//  return result;
//endfunction : getDceMasterTransIdForSNP
//
//static function sfi_transId_t getDceMasterTransIdForDvmSNP (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b110;
//  return result;
//endfunction : getDceMasterTransIdForDvmSNP
//
//static function bit checkDceMasterTransIdForSNP (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-2] == 2'b00) ? 1 : 0;
//endfunction : checkDceMasterTransIdForSNP
//
//static function bit checkDceMasterTransIdForDvmSNP (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b110) ? 1 : 0;
//endfunction : checkDceMasterTransIdForDvmSNP
//
//static function sfi_transId_t getDceMasterTransIdForSTR (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b101;
//  return result;
//endfunction : getDceMasterTransIdForSTR
//
//static function sfi_transId_t getDceMasterTransIdForDvmSTR (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b111;
//  return result;
//endfunction : getDceMasterTransIdForDvmSTR
//
//static function bit checkDceMasterTransIdForSTR (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b101) ? 1 : 0;
//endfunction : checkDceMasterTransIdForSTR
//
//static function bit checkDceMasterTransIdForDvmSTR (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b111) ? 1 : 0;
//endfunction : checkDceMasterTransIdForDvmSTR
//
//
//static function sfi_transId_t getDceMasterTransIdForHNT (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b100;
//  return result;
//endfunction : getDceMasterTransIdForHNT
//
//static function bit checkDceMasterTransIdForHNT (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b100) ? 1 : 0;
//endfunction : checkDceMasterTransIdForHNT
//
//static function sfi_transId_t getDceMasterTransIdForMRD (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-2] = 2'b01;
//  return result;
//endfunction : getDceMasterTransIdForMRD
//
//static function bit checkDceMasterTransIdForMRD (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-2] == 2'b01) ? 1 : 0;
//endfunction : checkDceMasterTransIdForMRD
///*
//static function sfi_transId_t getDceMasterTransIdForDVMs (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-4] = 4'b1110;
//  return result;
//endfunction : getDceMasterTransIdForDVMs
//
//static function bit checkDceMasterTransIdForDVMs (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-4] == 4'b1110) ? 1 : 0;
//endfunction : checkDceMasterTransIdForDVMs
//
//static function sfi_transId_t getDceMasterTransIdForDVMr (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-4] = 4'b1111;
//  return result;
//endfunction : getDceMasterTransIdForDVMr
//
//static function bit checkDceMasterTransIdForDVMr (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-4] == 4'b1111) ? 1 : 0;
//endfunction : checkDceMasterTransIdForDVMr
//*/
//////////////////////////////////////////////////////////////////////////////////
////
//// See Concerto AIU Architecture Spec, Table 20: ACE AIU Master TransID Encoding
//// Note: AIU Master Interface connects to SFI Slave Interface
//////////////////////////////////////////////////////////////////////////////////
//
//static function sfi_transId_t getAiuMasterTransIdForDTW (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1] = 1'b0;
//  return result;
//endfunction : getAiuMasterTransIdForDTW
//
//static function bit checkAiuMasterTransIdForDTW (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1] == 1'b0) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForDTW
//
///*
//static function sfi_transId_t getAiuMasterTransIdForCMDupd (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b100;
//  return result;
//endfunction : getAiuMasterTransIdForCMDupd
//
//static function bit checkAiuMasterTransIdForCMDupd (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b100) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForCMDupd
//*/
//
//static function sfi_transId_t getAiuMasterTransIdForCMDcoh (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b101;
//  return result;
//endfunction : getAiuMasterTransIdForCMDcoh
//
//static function bit checkAiuMasterTransIdForCMDcoh (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b101) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForCMDcoh
//
//static function sfi_transId_t getAiuMasterTransIdForDTR (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-3] = 3'b110;
//  return result;
//endfunction : getAiuMasterTransIdForDTR
//
//static function bit checkAiuMasterTransIdForDTR (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-3] == 3'b110) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForDTR
//
//static function sfi_transId_t getAiuMasterTransIdForDVMm (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-4] = 4'b1110;
//  return result;
//endfunction : getAiuMasterTransIdForDVMm
//
//static function bit checkAiuMasterTransIdForDVMm (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-4] == 4'b1110) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForDVMm
//
//static function sfi_transId_t getAiuMasterTransIdForDVMc (sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  result[SLV_WTRANSID-1:SLV_WTRANSID-4] = 4'b1111;
//  return result;
//endfunction : getAiuMasterTransIdForDVMc
//
//static function bit checkAiuMasterTransIdForDVMc (sfi_transId_t sfi_trans_id);
//  return (sfi_trans_id[SLV_WTRANSID-1:SLV_WTRANSID-4] == 4'b1111) ? 1 : 0;
//endfunction : checkAiuMasterTransIdForDVMc
//
//static function sfi_transId_t getAiuMasterTransId (eMsgCMD cmd, sfi_transId_t sfi_trans_id);
//  sfi_transId_t  result;
//  result = sfi_trans_id;
//  case (cmd)
//    eCmdDvmMsg : result = getAiuMasterTransIdForDVMm  (sfi_trans_id);
//    default         : result = getAiuMasterTransIdForCMDcoh(sfi_trans_id);
//  endcase
//  return result;
//endfunction : getAiuMasterTransId
//
//////////////////////////////////////////////////////////////////////////////////
////
//// See Concerto DMI Architecture Spec, Table 1: DMI Master TransID Encoding
//// Note: DMI Master Interface connects to SFI Slave Interface
//////////////////////////////////////////////////////////////////////////////////
//
//static function sfi_transId_t getDmiMasterTransIdForDTR (sfi_transId_t sfi_trans_id);
//  return sfi_trans_id;
//endfunction : getDmiMasterTransIdForDTR
//
////////////////////////////////////////////////////////////////////////////////
*/
