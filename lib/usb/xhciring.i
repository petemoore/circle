extern "C" {
 void assertion_failed (const char *pExpr, const char *pFile, unsigned nLine) __attribute__ ((noreturn));
}
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef unsigned long u64;
typedef signed long s64;
typedef long intptr;
typedef unsigned long uintptr;
typedef unsigned long size_t;
typedef long ssize_t;
typedef bool boolean;
static_assert (sizeof (boolean) == 1, "sizeof (boolean) == 1");
extern "C" {
struct TVectorTable
{
 struct
 {
  u32 Branch;
  u32 Dummy[31];
 }
 Vector[16];
}
__attribute__ ((packed));
struct TAbortFrame
{
 u64 esr_el1;
 u64 spsr_el1;
 u64 x30;
 u64 elr_el1;
 u64 sp_el0;
 u64 sp_el1;
 u64 far_el1;
 u64 unused;
}
__attribute__ ((packed));
void ExceptionHandler (u64 nException, TAbortFrame *pFrame);
void InterruptHandler (void);
void SMCStub (void);
void UnexpectedStub (void);
void SecureMonitorHandler (u32 nFunction, u32 nParam);
typedef void TFIQHandler (void *pParam);
struct TFIQData
{
 TFIQHandler *pHandler;
 void *pParam;
 u32 nFIQNumber;
}
__attribute__ ((packed));
extern TFIQData FIQData;
extern uintptr IRQReturnAddress;
}
typedef void TIRQHandler (void *pParam);
class CInterruptSystem
{
public:
 CInterruptSystem (void);
 ~CInterruptSystem (void);
 void Destructor (void);
 boolean Initialize (void);
 void ConnectIRQ (unsigned nIRQ, TIRQHandler *pHandler, void *pParam);
 void DisconnectIRQ (unsigned nIRQ);
 void ConnectFIQ (unsigned nFIQ, TFIQHandler *pHandler, void *pParam);
 void DisconnectFIQ (void);
 static void EnableIRQ (unsigned nIRQ);
 static void DisableIRQ (unsigned nIRQ);
 static void EnableFIQ (unsigned nFIQ);
 static void DisableFIQ (void);
 static CInterruptSystem *Get (void);
 static void InterruptHandler (void);
 static void InitializeSecondary (void);
 static void SendIPI (unsigned nCore, unsigned nIPI);
 static void CallSecureMonitor (u32 nFunction, u32 nParam);
 static void SecureMonitorHandler (u32 nFunction, u32 nParam);
private:
 boolean CallIRQHandler (unsigned nIRQ);
private:
 TIRQHandler *m_apIRQHandler[256];
 void *m_pParam[256];
 static CInterruptSystem *s_pThis;
};
typedef __builtin_va_list va_list;
class CString
{
public:
 CString (void);
 CString (const char *pString);
 CString (const CString &rString);
 CString (CString &&rrString);
 virtual ~CString (void);
 operator const char *(void) const;
 const char *operator = (const char *pString);
 CString &operator = (const CString &rString);
 CString &operator = (CString &&rrString);
 CString &operator += (const char chChar);
 CString &operator += (const char *pString);
 CString &operator += (const CString &rString);
 const char* c_str (void) const;
 size_t GetLength (void) const;
 void Append (const char *pString);
 void Append (const char chChar);
 int Compare (const char *pString) const;
 int Find (char chChar) const;
 int Replace (const char *pOld, const char *pNew);
 void Format (const char *pFormat, ...);
 void FormatV (const char *pFormat, va_list Args);
private:
 void PutChar (char chChar, size_t nCount = 1);
 void PutString (const char *pString);
 void ReserveSpace (size_t nSpace);
 static char *ntoa (char *pDest, unsigned long ulNumber, unsigned nBase, boolean bUpcase);
 static char *lltoa (char *pDest, unsigned long long ullNumber, unsigned nBase, boolean bUpcase);
 static char *ftoa (char *pDest, double fNumber, unsigned nPrecision);
private:
 char *m_pBuffer;
 unsigned m_nSize;
 char *m_pInPtr;
};
struct TPtrListElement;
class CPtrList
{
public:
 CPtrList (void);
 ~CPtrList (void);
 TPtrListElement *GetFirst (void) const;
 TPtrListElement *GetNext (TPtrListElement *pElement) const;
 static void *GetPtr (TPtrListElement *pElement);
 void InsertBefore (TPtrListElement *pAfter, void *pPtr);
 void InsertAfter (TPtrListElement *pBefore, void *pPtr);
 void Remove (TPtrListElement *pElement);
 TPtrListElement *Find (void *pPtr) const;
private:
 TPtrListElement *m_pFirst;
};
extern "C" {
unsigned CurrentExecutionLevel (void);
void EnterCritical (unsigned nTargetLevel = 1);
void LeaveCritical (void);
void InvalidateDataCache (void) __attribute__ ((optimize (3)));
void InvalidateDataCacheL1Only (void) __attribute__ ((optimize (3)));
void CleanDataCache (void) __attribute__ ((optimize (3)));
void InvalidateDataCacheRange (u64 nAddress, u64 nLength) __attribute__ ((optimize (3)));
void CleanDataCacheRange (u64 nAddress, u64 nLength) __attribute__ ((optimize (3)));
void CleanAndInvalidateDataCacheRange (u64 nAddress, u64 nLength) __attribute__ ((optimize (3)));
void SyncDataAndInstructionCache (void);
}
class CSpinLock
{
public:
 CSpinLock (unsigned nTargetLevel = 1)
 : m_nTargetLevel (nTargetLevel)
 {
 }
 void Acquire (void)
 {
  if (m_nTargetLevel >= 1)
  {
   EnterCritical (m_nTargetLevel);
  }
 }
 void Release (void)
 {
  if (m_nTargetLevel >= 1)
  {
   LeaveCritical ();
  }
 }
private:
 unsigned m_nTargetLevel;
};
typedef uintptr TKernelTimerHandle;
typedef void TKernelTimerHandler (TKernelTimerHandle hTimer, void *pParam, void *pContext);
typedef boolean TUpdateTimeHandler (unsigned nNewTime, unsigned nOldTime);
typedef void TPeriodicTimerHandler (void);
extern "C" void DelayLoop (unsigned nCount);
class CTimer
{
public:
 CTimer (CInterruptSystem *pInterruptSystem);
 ~CTimer (void);
 boolean Initialize (void);
 boolean SetTimeZone (int nMinutesDiff);
 int GetTimeZone (void) const;
 boolean SetTime (unsigned nTime, boolean bLocal = true);
 static unsigned GetClockTicks (void);
 static u64 GetClockTicks64 (void);
 unsigned GetTicks (void) const;
 unsigned GetUptime (void) const;
 unsigned GetTime (void) const;
 unsigned GetLocalTime (void) const { return GetTime (); }
 boolean GetLocalTime (unsigned *pSeconds, unsigned *pMicroSeconds);
 unsigned GetUniversalTime (void) const;
 boolean GetUniversalTime (unsigned *pSeconds, unsigned *pMicroSeconds);
 CString *GetTimeString (void);
 TKernelTimerHandle StartKernelTimer (unsigned nDelay,
          TKernelTimerHandler *pHandler,
          void *pParam = 0,
          void *pContext = 0);
 void CancelKernelTimer (TKernelTimerHandle hTimer);
 void MsDelay (unsigned nMilliSeconds) { SimpleMsDelay (nMilliSeconds); }
 void usDelay (unsigned nMicroSeconds) { SimpleusDelay (nMicroSeconds); }
 void nsDelay (unsigned nNanoSeconds) { DelayLoop (m_nusDelay * nNanoSeconds / 1000); }
 static CTimer *Get (void);
 static void SimpleMsDelay (unsigned nMilliSeconds);
 static void SimpleusDelay (unsigned nMicroSeconds);
 void RegisterUpdateTimeHandler (TUpdateTimeHandler *pHandler);
 void RegisterPeriodicHandler (TPeriodicTimerHandler *pHandler);
private:
 void PollKernelTimers (void);
 void InterruptHandler (void);
 static void InterruptHandler (void *pParam);
 void TuneMsDelay (void);
public:
 static int IsLeapYear (unsigned nYear);
 static unsigned GetDaysOfMonth (unsigned nMonth, unsigned nYear);
private:
 CInterruptSystem *m_pInterruptSystem;
 u32 m_nClockTicksPerHZTick;
 volatile unsigned m_nTicks;
 volatile unsigned m_nUptime;
 volatile unsigned m_nTime;
 CSpinLock m_TimeSpinLock;
 int m_nMinutesDiff;
 CPtrList m_KernelTimerList;
 CSpinLock m_KernelTimerSpinLock;
 unsigned m_nMsDelay;
 unsigned m_nusDelay;
 TUpdateTimeHandler *m_pUpdateTimeHandler;
 TPeriodicTimerHandler *m_pPeriodicHandler[4];
 volatile unsigned m_nPeriodicHandlers;
 static CTimer *s_pThis;
 static const unsigned s_nDaysOfMonth[12];
 static const char *s_pMonthName[12];
};
struct TPCIeMemoryWindow
{
 u64 pcie_addr;
 u64 cpu_addr;
 u64 size;
};
typedef void TPCIeMSIHandler (unsigned nVector, void *pParam);
struct TPCIeMSIData
{
 uintptr base;
 u64 target_addr;
 uintptr intr_base;
 unsigned rev;
 TPCIeMSIHandler *handler;
 void *param;
};
class CBcmPCIeHostBridge
{
public:
 CBcmPCIeHostBridge (CInterruptSystem *pInterrupt);
 ~CBcmPCIeHostBridge (void);
 boolean Initialize (void);
 boolean EnableDevice (u32 nClassCode, unsigned nSlot, unsigned nFunc);
 boolean ConnectMSI (TPCIeMSIHandler *pHandler, void *pParam);
 void DisconnectMSI (void);
 static u64 GetDMAAddress (void)
 {
  return s_nDMAAddress;
 }
 void DumpStatus (unsigned nSlot, unsigned nFunc);
private:
 int pcie_probe(void);
 int pcie_setup(void);
 int enable_bridge (void);
 int enable_device (u32 nClassCode, unsigned nSlot, unsigned nFunc);
 int pcie_set_pci_ranges(void);
 int pcie_set_dma_ranges(void);
 void pcie_set_outbound_win(unsigned win, u64 cpu_addr, u64 pcie_addr, u64 size);
 uintptr pcie_map_conf(unsigned busnr, unsigned devfn, int where);
 static uintptr find_pci_capability (uintptr nPCIConfig, u8 uchCapID);
 void pcie_bridge_sw_init_set(unsigned val);
 void pcie_perst_set(unsigned int val);
 bool pcie_link_up(void);
 bool pcie_rc_mode(void);
 int pcie_enable_msi(TPCIeMSIHandler *pHandler, void *pParam);
 static void msi_set_regs(TPCIeMSIData *msi);
 static int cfg_index(int busnr, int devfn, int reg);
 static void set_gen(uintptr base, int gen);
 static const char *link_speed_to_str(int s);
 static int encode_ibar_size(u64 size);
 static u32 rd_fld(uintptr p, u32 mask, int shift);
 static void wr_fld(uintptr p, u32 mask, int shift, u32 val);
 static void wr_fld_rb(uintptr p, u32 mask, int shift, u32 val);
 static void InterruptHandler (void *pParam);
 void usleep_range (unsigned min, unsigned max);
 void msleep (unsigned ms);
 static int ilog2 (u64 v);
private:
 CInterruptSystem *m_pInterrupt;
 uintptr m_base;
 unsigned m_rev;
 TPCIeMemoryWindow m_out_wins[1];
 int m_num_out_wins;
 TPCIeMemoryWindow m_dma_ranges[1];
 int m_num_dma_ranges;
 u64 m_scb_size[1];
 int m_num_scbs;
 u64 m_msi_target_addr;
 TPCIeMSIData *m_msi;
 static u64 s_nDMAAddress;
};
struct TXHCITRB
{
 union
 {
  struct
  {
   u32 Parameter1;
   u32 Parameter2;
  };
  u64 Parameter;
 };
 u32 Status;
 u32 Control;
}
__attribute__ ((packed));
struct TXHCIERSTEntry
{
 u64 RingSegmentBase;
 u32 RingSegmentSize;
 u32 Reserved;
}
__attribute__ ((packed));
struct TXHCISlotContext
{
 u32 RouteString : 20,
  Speed : 4,
  RsvdZ1 : 1,
  MTT : 1,
  Hub : 1,
  ContextEntries : 5;
 u32 MaxExitLatency : 16,
  RootHubPortNumber : 8,
  NumberOfPorts : 8;
 u32 TTHubSlotID : 8,
  TTPortNumber : 8,
  TTT : 2,
  RsvdZ2 : 4,
  InterrupterTarget : 10;
 u32 USBDeviceAddress : 8,
  RsvdZ3 : 19,
  SlotState : 5;
 u32 RsvdO[4];
}
__attribute__ ((packed));
static_assert (sizeof (TXHCISlotContext) == 0x20, "sizeof (TXHCISlotContext) == 0x20");
struct TXHCIEndpointContext
{
 u32 EPState : 3,
  RsvdZ1 : 5,
  Mult : 2,
  MaxPStreams : 5,
  LSA : 1,
  Interval : 8,
  RsvdZ2 : 8;
 u32 RsvdZ3 : 1,
  CErr : 2,
  EPType : 3,
  RsvdZ4 : 1,
  HID : 1,
  MaxBurstSize : 8,
  MaxPacketSize : 16;
 u64 TRDequeuePointer;
 u32 AverageTRBLength : 16,
  MaxESITPayload : 16;
 u32 RsvdO[3];
}
__attribute__ ((packed));
static_assert (sizeof (TXHCIEndpointContext) == 0x20, "sizeof (TXHCIEndpointContext) == 0x20");
struct TXHCIDeviceContext
{
 TXHCISlotContext Slot;
 TXHCIEndpointContext Endpoint[31];
}
__attribute__ ((packed));
static_assert (sizeof (TXHCIDeviceContext) == 0x400, "sizeof (TXHCIDeviceContext) == 0x400");
struct TXHCIInputControlContext
{
 u32 DropContextFlags;
 u32 AddContextFlags;
 u32 RsvdZ[6];
}
__attribute__ ((packed));
static_assert (sizeof (TXHCIInputControlContext) == 0x20, "sizeof (TXHCIInputControlContext) == 0x20");
struct TXHCIInputContext
{
 TXHCIInputControlContext Control;
 TXHCIDeviceContext Device;
}
__attribute__ ((packed));
static_assert (sizeof (TXHCIInputContext) == 0x420, "sizeof (TXHCIInputContext) == 0x420");
enum TXHCIRingType
{
 XHCIRingTypeTransfer,
 XHCIRingTypeEvent,
 XHCIRingTypeCommand,
 XHCIRingTypeUnknown
};
class CXHCIDevice;
class CXHCIRing
{
public:
 CXHCIRing (TXHCIRingType Type, unsigned nTRBCount, CXHCIDevice *pAllocator);
 ~CXHCIRing (void);
 boolean IsValid (void) const;
 unsigned GetTRBCount (void) const;
 TXHCITRB *GetFirstTRB (void);
 TXHCITRB *GetDequeueTRB (void);
 TXHCITRB *GetEnqueueTRB (void);
 TXHCITRB *IncrementDequeue (void);
 void IncrementEnqueue (void);
 u32 GetCycleState (void) const;
 void DumpStatus (const char *pFrom = 0);
private:
 TXHCIRingType m_Type;
 unsigned m_nTRBCount;
 CXHCIDevice *m_pAllocator;
 TXHCITRB *m_pFirstTRB;
 unsigned m_nEnqueueIndex;
 unsigned m_nDequeueIndex;
 u32 m_nCycleState;
};
class CUSBController
{
public:
 virtual boolean Initialize (boolean bScanDevices = true) = 0;
 virtual boolean UpdatePlugAndPlay (void) = 0;
};
struct TUSBAudioEndpointDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bEndpointAddress;
 unsigned char bmAttributes;
 unsigned short wMaxPacketSize;
 unsigned char bInterval;
 unsigned char bRefresh;
 unsigned char bSynchAddress;
}
__attribute__ ((packed));
struct TUSBMIDIStreamingEndpointDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubType;
 unsigned char bNumEmbMIDIJack;
 unsigned char bAssocJackIDs[1];
}
__attribute__ ((packed));
struct TUSBMIDIStreamingInterfaceDescriptorHeader
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 unsigned short bcdADC;
 unsigned short wTotalLength;
}
__attribute__ ((packed));
struct TUSBMIDIStreamingInterfaceDescriptorInJack
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 unsigned char bJackType;
 unsigned char bJackID;
 unsigned char iJack;
}
__attribute__ ((packed));
struct TUSBMIDIStreamingInterfaceDescriptorOutJack
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 unsigned char bJackType;
 unsigned char bJackID;
 unsigned char bNrInputPins;
 unsigned char baSourceID[1];
 unsigned char baSourcePin[1];
 unsigned char iJack;
}
__attribute__ ((packed));
struct TUSBAudioControlInterfaceDescriptorHeader
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 unsigned short bcdADC;
 unsigned short wTotalLength;
 unsigned char bInCollection;
 unsigned char baInterfaceNr[1];
}
__attribute__ ((packed));
struct TUSBAudioControlInterfaceDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 union
 {
  union
  {
   struct
   {
    unsigned short bcdADC __attribute__ ((packed));
    unsigned short wTotalLength __attribute__ ((packed));
    unsigned char bInCollection;
    unsigned char baInterfaceNr[];
   }
   Header;
   struct
   {
    unsigned char bTerminalID;
    unsigned short wTerminalType __attribute__ ((packed));
    unsigned char bAssocTerminal;
    unsigned char bNrChannels;
    unsigned short wChannelConfig __attribute__ ((packed));
    unsigned char iChannelNames;
    unsigned char iTerminal;
   }
   InputTerminal;
   struct
   {
    unsigned char bTerminalID;
    unsigned short wTerminalType __attribute__ ((packed));
    unsigned char bAssocTerminal;
    unsigned char bSourceID;
    unsigned char iTerminal;
   }
   OutputTerminal;
   struct
   {
    unsigned char bUnitID;
    unsigned char bNrInPins;
    unsigned char baSourceID[];
   }
   MixerUnit;
   struct
   {
    unsigned char bUnitID;
    unsigned char bNrInPins;
    unsigned char baSourceID[];
   }
   SelectorUnit;
   struct
   {
    unsigned char bUnitID;
    unsigned char bSourceID;
    unsigned char bControlSize;
    unsigned char bmaControls[];
   }
   FeatureUnit;
  }
  Ver100;
  union
  {
   struct
   {
    unsigned short bcdADC __attribute__ ((packed));
    unsigned char bCategory;
    unsigned short wTotalLength __attribute__ ((packed));
    unsigned char bmControls;
   }
   Header;
   struct
   {
    unsigned char bTerminalID;
    unsigned short wTerminalType __attribute__ ((packed));
    unsigned char bAssocTerminal;
    unsigned char bCSourceID;
    unsigned char bNrChannels;
    unsigned int bmChannelConfig __attribute__ ((packed));
    unsigned char iChannelNames;
    unsigned short bmControls __attribute__ ((packed));
    unsigned char iTerminal;
   }
   InputTerminal;
   struct
   {
    unsigned char bTerminalID;
    unsigned short wTerminalType __attribute__ ((packed));
    unsigned char bAssocTerminal;
    unsigned char bSourceID;
    unsigned char bCSourceID;
    unsigned short bmControls __attribute__ ((packed));
    unsigned char iTerminal;
   }
   OutputTerminal;
   struct
   {
    unsigned char bUnitID;
    unsigned char bNrInPins;
    unsigned char baSourceID[];
   }
   MixerUnit;
   struct
   {
    unsigned char bUnitID;
    unsigned char bNrInPins;
    unsigned char baSourceID[];
   }
   SelectorUnit;
   struct
   {
    unsigned char bUnitID;
    unsigned char bSourceID;
    unsigned int bmaControls[] __attribute__ ((packed));
   }
   FeatureUnit;
   struct
   {
    unsigned char bClockID;
    unsigned char bmAttributes;
    unsigned char bmControls;
    unsigned char bAssocTerminal;
    unsigned char iClockSource;
   }
   ClockSource;
   struct
   {
    unsigned char bClockID;
    unsigned char bNrInPins;
    unsigned char baCSourceID[];
   }
   ClockSelector;
  }
  Ver200;
 };
}
__attribute__ ((packed));
struct TUSBAudioControlMixerUnitTrailerVer100
{
 unsigned char bNrChannels;
 unsigned short wChannelConfig __attribute__ ((packed));
 unsigned char iChannelNames;
 unsigned char bmControls[];
}
__attribute__ ((packed));
struct TUSBAudioControlMixerUnitTrailerVer200
{
 unsigned char bNrChannels;
 unsigned int bmChannelConfig __attribute__ ((packed));
 unsigned char iChannelNames;
 unsigned char bmMixerControls[];
}
__attribute__ ((packed));
struct TUSBAudioStreamingInterfaceDescriptor
{
        unsigned char bLength;
        unsigned char bDescriptorType;
        unsigned char bDescriptorSubtype;
 union
 {
  struct
  {
   unsigned char bTerminalLink;
   unsigned char bDelay;
   unsigned short wFormatTag __attribute__ ((packed));
  }
  Ver100;
  struct
  {
   unsigned char bTerminalLink;
   unsigned char bmControls;
   unsigned char bFormatType;
   unsigned int bmFormats __attribute__ ((packed));
   unsigned char bNrChannels;
   unsigned int bmChannelConfig __attribute__ ((packed));
   unsigned char iChannelNames;
  }
  Ver200;
 };
}
__attribute__ ((packed));
struct TUSBAudioTypeIFormatTypeDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bDescriptorSubtype;
 unsigned char bFormatType;
 union
 {
  struct
  {
   unsigned char bNrChannels;
   unsigned char bSubframeSize;
   unsigned char bBitResolution;
   unsigned char bSamFreqType;
   unsigned char tSamFreq[][3];
  }
  Ver100;
  struct
  {
   unsigned char bSubslotSize;
   unsigned char bBitResolution;
  }
  Ver200;
 };
}
__attribute__ ((packed));
enum TUSBPID
{
 USBPIDSetup,
 USBPIDData0,
 USBPIDData1,
};
enum TUSBSpeed
{
 USBSpeedLow,
 USBSpeedFull,
 USBSpeedHigh,
 USBSpeedSuper,
 USBSpeedUnknown
};
enum TUSBError
{
 USBErrorStall,
 USBErrorTransaction,
 USBErrorBabble,
 USBErrorFrameOverrun,
 USBErrorDataToggle,
 USBErrorHostBus,
 USBErrorSplit,
 USBErrorTimeout,
 USBErrorAborted,
 USBErrorUnknown
};
struct TSetupData
{
 unsigned char bmRequestType;
 unsigned char bRequest;
 unsigned short wValue;
 unsigned short wIndex;
 unsigned short wLength;
}
__attribute__ ((packed));
struct TUSBDeviceDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned short bcdUSB;
 unsigned char bDeviceClass;
 unsigned char bDeviceSubClass;
 unsigned char bDeviceProtocol;
 unsigned char bMaxPacketSize0;
 unsigned short idVendor;
 unsigned short idProduct;
 unsigned short bcdDevice;
 unsigned char iManufacturer;
 unsigned char iProduct;
 unsigned char iSerialNumber;
 unsigned char bNumConfigurations;
}
__attribute__ ((packed));
struct TUSBConfigurationDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned short wTotalLength;
 unsigned char bNumInterfaces;
 unsigned char bConfigurationValue;
 unsigned char iConfiguration;
 unsigned char bmAttributes;
 unsigned char bMaxPower;
}
__attribute__ ((packed));
struct TUSBInterfaceDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bInterfaceNumber;
 unsigned char bAlternateSetting;
 unsigned char bNumEndpoints;
 unsigned char bInterfaceClass;
 unsigned char bInterfaceSubClass;
 unsigned char bInterfaceProtocol;
 unsigned char iInterface;
}
__attribute__ ((packed));
struct TUSBEndpointDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned char bEndpointAddress;
 unsigned char bmAttributes;
 unsigned short wMaxPacketSize;
 unsigned char bInterval;
}
__attribute__ ((packed));
union TUSBDescriptor
{
 struct
 {
  unsigned char bLength;
  unsigned char bDescriptorType;
 }
 Header;
 TUSBConfigurationDescriptor Configuration;
 TUSBInterfaceDescriptor Interface;
 TUSBEndpointDescriptor Endpoint;
 TUSBAudioEndpointDescriptor AudioEndpoint;
 TUSBMIDIStreamingEndpointDescriptor MIDIStreamingEndpoint;
}
__attribute__ ((packed));
struct TUSBStringDescriptor
{
 unsigned char bLength;
 unsigned char bDescriptorType;
 unsigned short bString[0];
}
__attribute__ ((packed));
class CUSBConfigurationParser
{
public:
 CUSBConfigurationParser (const void *pBuffer, unsigned nBufLen);
 CUSBConfigurationParser (CUSBConfigurationParser *pParser);
 ~CUSBConfigurationParser (void);
 boolean IsValid (void) const;
 const TUSBDescriptor *GetDescriptor (u8 ucType);
 const TUSBDescriptor *GetCurrentDescriptor (void);
 void Error (const char *pSource) const;
private:
 const TUSBDescriptor *m_pBuffer;
 unsigned m_nBufLen;
 boolean m_bValid;
 const TUSBDescriptor *m_pEndPosition;
 const TUSBDescriptor *m_pNextPosition;
 const TUSBDescriptor *m_pCurrentDescriptor;
 const TUSBDescriptor *m_pErrorPosition;
};
class CDevice;
typedef void TDeviceRemovedHandler (CDevice *pDevice, void *pContext);
class CDevice
{
public:
 CDevice (void);
 virtual ~CDevice (void);
 virtual int Read (void *pBuffer, size_t nCount);
 virtual int Write (const void *pBuffer, size_t nCount);
 virtual u64 Seek (u64 ullOffset);
 virtual u64 GetSize (void) const;
 virtual int IOCtl (unsigned long ulCmd, void *pData);
 virtual boolean RemoveDevice (void);
public:
 typedef void *TRegistrationHandle;
 TRegistrationHandle RegisterRemovedHandler (TDeviceRemovedHandler *pHandler,
          void *pContext = 0);
 void UnregisterRemovedHandler (TRegistrationHandle hRegistration);
private:
 CPtrList m_RemovedHandlerList;
};
struct TUSBHubDescriptor
{
 unsigned char bDescLength;
 unsigned char bDescriptorType;
 unsigned char bNbrPorts;
 unsigned short wHubCharacteristics;
 unsigned char bPwrOn2PwrGood;
 unsigned char bHubContrCurrent;
 unsigned char DeviceRemoveable[1];
 unsigned char PortPwrCtrlMask[1];
}
__attribute__ ((packed));
struct TUSBHubStatus
{
 unsigned short wHubStatus;
 unsigned short wHubChange;
}
__attribute__ ((packed));
struct TUSBPortStatus
{
 unsigned short wPortStatus;
 unsigned short wChangeStatus;
}
__attribute__ ((packed));
struct TUSBHubInfo
{
 unsigned NumberOfPorts;
 boolean HasMultipleTTs;
 u8 TTThinkTime;
};
class CUSBDevice;
class CUSBHostController;
class CUSBEndpoint;
class CUSBFunction : public CDevice
{
public:
 CUSBFunction (CUSBDevice *pDevice, CUSBConfigurationParser *pConfigParser);
 CUSBFunction (CUSBFunction *pFunction);
 virtual ~CUSBFunction (void);
 virtual boolean Initialize (void);
 virtual boolean Configure (void);
 virtual boolean ReScanDevices (void);
 virtual boolean RemoveDevice (void);
 CString *GetInterfaceName (void) const;
 u8 GetNumEndpoints (void) const;
 CUSBDevice *GetDevice (void) const;
 CUSBEndpoint *GetEndpoint0 (void) const;
 CUSBHostController *GetHost (void) const;
 const TUSBDescriptor *GetDescriptor (u8 ucType);
 void ConfigurationError (const char *pSource) const;
 boolean SelectInterfaceByClass (u8 uchClass, u8 uchSubClass, u8 uchProtocol,
     unsigned nMinEndpoints = 0);
 u8 GetInterfaceNumber (void) const;
 u8 GetInterfaceClass (void) const;
 u8 GetInterfaceSubClass (void) const;
 u8 GetInterfaceProtocol (void) const;
 const TUSBInterfaceDescriptor *GetInterfaceDescriptor (void) const;
 virtual const TUSBHubInfo *GetHubInfo (void) const { return 0; }
private:
 CUSBDevice *m_pDevice;
 CUSBConfigurationParser *m_pConfigParser;
 TUSBInterfaceDescriptor *m_pInterfaceDesc;
};
class CNumberPool
{
public:
 static const unsigned Limit = 63;
 static const unsigned Invalid = Limit+1;
public:
 CNumberPool (unsigned nMin, unsigned nMax = Limit);
 ~CNumberPool (void);
 unsigned AllocateNumber (boolean bMustSucceed, const char *pFrom = "numpool");
 void FreeNumber (unsigned nNumber);
private:
 unsigned m_nMin;
 unsigned m_nMax;
 u64 m_nMap;
};
typedef signed long time_t;
class CTime
{
public:
 CTime (void);
 CTime (const CTime &rSource);
 ~CTime (void);
 void Set (time_t Time);
 boolean SetTime (unsigned nHours, unsigned nMinutes, unsigned nSeconds);
 boolean SetDate (unsigned nMonthDay, unsigned nMonth, unsigned nYear);
 time_t Get (void) const;
 unsigned GetSeconds (void) const;
 unsigned GetMinutes (void) const;
 unsigned GetHours (void) const;
 unsigned GetMonthDay (void) const;
 unsigned GetMonth (void) const;
 unsigned GetYear (void) const;
 unsigned GetWeekDay (void) const;
 const char *GetString (void);
private:
 static boolean IsLeapYear (unsigned nYear);
 static unsigned GetDaysOfMonth (unsigned nMonth, unsigned nYear);
private:
 unsigned m_nSeconds;
 unsigned m_nMinutes;
 unsigned m_nHours;
 unsigned m_nMonthDay;
 unsigned m_nMonth;
 unsigned m_nYear;
 unsigned m_nWeekDay;
 CString m_String;
 static const unsigned s_nDaysOfMonth[];
 static const char *s_pMonthName[];
 static const char *s_pDaysOfWeek[];
};
enum TLogSeverity
{
 LogPanic,
 LogError,
 LogWarning,
 LogNotice,
 LogDebug
};
struct TLogEvent;
typedef void TLogEventNotificationHandler (void);
typedef void TLogPanicHandler (void);
class CLogger
{
public:
 CLogger (unsigned nLogLevel, CTimer *pTimer = 0, boolean bOverwriteOldest = true);
 ~CLogger (void);
 boolean Initialize (CDevice *pTarget);
 void SetNewTarget (CDevice *pTarget);
 void Write (const char *pSource, TLogSeverity Severity, const char *pMessage, ...);
 void WriteV (const char *pSource, TLogSeverity Severity, const char *pMessage, va_list Args);
 void WriteNoAlloc (const char *pSource, TLogSeverity Severity, const char *pMessage);
 int Read (void *pBuffer, unsigned nCount, boolean bClear = true);
 boolean ReadEvent (TLogSeverity *pSeverity, char *pSource, char *pMessage,
      time_t *pTime, unsigned *pHundredthTime, int *pTimeZone);
 void RegisterEventNotificationHandler (TLogEventNotificationHandler *pHandler);
 void RegisterPanicHandler (TLogPanicHandler *pHandler);
 static CLogger *Get (void);
private:
 void Write (const char *pString);
 void WriteEvent (const char *pSource, TLogSeverity Severity, const char *pMessage);
private:
 unsigned m_nLogLevel;
 CTimer *m_pTimer;
 boolean m_bOverwriteOldest;
 CDevice *m_pTarget;
 char *m_pBuffer;
 unsigned m_nInPtr;
 unsigned m_nOutPtr;
 CSpinLock m_SpinLock;
 TLogEvent *m_pEventQueue[50];
 unsigned m_nEventInPtr;
 unsigned m_nEventOutPtr;
 CSpinLock m_EventSpinLock;
 TLogEventNotificationHandler *m_pEventNotificationHandler;
 TLogPanicHandler *m_pPanicHandler;
 boolean m_bEnabled;
 static CLogger *s_pThis;
};
enum TDeviceNameSelector
{
 DeviceNameVendor,
 DeviceNameDevice,
 DeviceNameUnknown
};
class CUSBHostController;
class CUSBHCIRootPort;
class CUSBStandardHub;
class CUSBEndpoint;
class CUSBDevice
{
public:
 CUSBDevice (CUSBHostController *pHost, TUSBSpeed Speed, CUSBHCIRootPort *pRootPort);
 CUSBDevice (CUSBHostController *pHost, TUSBSpeed Speed,
      CUSBStandardHub *pHub, unsigned nHubPortIndex);
 virtual ~CUSBDevice (void);
 virtual boolean Initialize (void);
 virtual boolean Configure (void);
 boolean ReScanDevices (void);
 boolean RemoveDevice (void);
 CString *GetName (TDeviceNameSelector Selector) const;
 CString *GetNames (void) const;
 u8 GetAddress (void) const;
 TUSBSpeed GetSpeed (void) const;
 boolean IsSplit (void) const;
 u8 GetHubAddress (void) const;
 u8 GetHubPortNumber (void) const;
 CUSBDevice *GetTTHubDevice (void) const;
 CUSBEndpoint *GetEndpoint0 (void) const;
 CUSBHostController *GetHost (void) const;
 const TUSBDeviceDescriptor *GetDeviceDescriptor (void) const;
 const TUSBConfigurationDescriptor *GetConfigurationDescriptor (void) const;
 const TUSBDescriptor *GetDescriptor (u8 ucType);
 void ConfigurationError (const char *pSource) const;
 CUSBFunction *GetFunction (unsigned nIndex);
 void LogWrite (TLogSeverity Severity, const char *pMessage, ...);
 virtual boolean EnableHubFunction (void) = 0;
 unsigned GetRootHubPortID (void) const { return m_nRootHubPortID; }
 u32 GetRouteString (void) const { return m_nRouteString; }
 const TUSBHubInfo *GetHubInfo (void) const
 {
  return m_pFunction[0] != 0 ? m_pFunction[0]->GetHubInfo () : 0;
 }
protected:
 void SetAddress (u8 ucAddress);
private:
 static u32 AppendPortToRouteString (u32 nRouteString, unsigned nPort);
private:
 CUSBHostController *m_pHost;
 CUSBHCIRootPort *m_pRootPort;
 CUSBStandardHub *m_pHub;
 unsigned m_nHubPortIndex;
 u8 m_ucAddress;
 TUSBSpeed m_Speed;
 CUSBEndpoint *m_pEndpoint0;
 boolean m_bSplitTransfer;
 u8 m_ucHubAddress;
 u8 m_ucHubPortNumber;
 CUSBDevice *m_pTTHubDevice;
 TUSBDeviceDescriptor *m_pDeviceDesc;
 TUSBConfigurationDescriptor *m_pConfigDesc;
 CUSBConfigurationParser *m_pConfigParser;
 CUSBFunction *m_pFunction[10];
 unsigned m_nRootHubPortID;
 u32 m_nRouteString;
};
class CXHCIMMIOSpace
{
public:
 CXHCIMMIOSpace (uintptr nBaseAddress);
 ~CXHCIMMIOSpace (void);
 u32 cap_read32 (u32 nOffset);
 u32 op_read32 (u32 nOffset);
 u32 pt_read32 (unsigned nPort, u32 nOffset);
 u32 rt_read32 (u32 nOffset);
 u32 rt_read32 (unsigned nInterrupter, u32 nOffset);
 u64 rt_read64 (unsigned nInterrupter, u32 nOffset);
 void op_write32 (u32 nOffset, u32 nValue);
 void db_write32 (unsigned nSlot, u32 nValue);
 void pt_write32 (unsigned nPort, u32 nOffset, u32 nValue);
 void rt_write32 (unsigned nInterrupter, u32 nOffset, u32 nValue);
 void op_write64 (u32 nOffset, u64 nValue);
 void rt_write64 (unsigned nInterrupter, u32 nOffset, u64 nValue);
 boolean op_wait32 (u32 nOffset, u32 nMask, u32 nExpectedValue, unsigned nTimeoutUsecs);
 void DumpStatus (void);
private:
 u32 cap_read32_raw (u32 nOffset);
private:
 uintptr m_nBase;
 uintptr m_nOpBase;
 uintptr m_nDbBase;
 uintptr m_nRtBase;
 uintptr m_nPtBase;
 uintptr m_nxECPBase;
 u32 m_nHCxParams[4];
};
class CXHCIDevice;
class CXHCIUSBDevice;
class CUSBRequest;
class CXHCIEndpoint
{
public:
 CXHCIEndpoint (CXHCIUSBDevice *pDevice, CXHCIDevice *pXHCIDevice);
 CXHCIEndpoint (CXHCIUSBDevice *pDevice, const TUSBEndpointDescriptor *pDesc,
         CXHCIDevice *pXHCIDevice);
 ~CXHCIEndpoint (void);
 boolean IsValid (void);
 CXHCIRing *GetTransferRing (void);
 boolean SetMaxPacketSize (u32 nMaxPacketSize);
 boolean Transfer (CUSBRequest *pURB, unsigned nTimeoutMs);
 boolean TransferAsync (CUSBRequest *pURB, unsigned nTimeoutMs);
 void TransferEvent (u8 uchCompletionCode, u32 nTransferLength);
 boolean ResetFromHalted (void);
 void DumpStatus (void);
private:
 static void CompletionRoutine (CUSBRequest *pURB, void *pParam, void *pContext);
 boolean EnqueueTRB (u32 nControl, u32 nStatus = 0,
       u32 nParameter1 = 0, u32 nParameter2 = 0);
 TXHCIInputContext *GetInputContextSetMaxPacketSize (void);
 TXHCIInputContext *GetInputContextConfigureEndpoint (void);
 void FreeInputContext (void);
 static u8 ConvertInterval (u8 uchInterval, TUSBSpeed Speed);
private:
 CXHCIUSBDevice *m_pDevice;
 CXHCIDevice *m_pXHCIDevice;
 CXHCIMMIOSpace *m_pMMIO;
 boolean m_bValid;
 CXHCIRing *m_pTransferRing;
 u8 m_uchEndpointAddress;
 u8 m_uchAttributes;
 u16 m_usMaxPacketSize;
 u8 m_uchInterval;
 u8 m_uchEndpointID;
 u8 m_uchEndpointType;
 CUSBRequest *m_pURB[2];
 volatile boolean m_bTransferCompleted;
 u8 *m_pInputContextBuffer;
 CSpinLock m_SpinLock;
};
enum TEndpointType
{
 EndpointTypeControl,
 EndpointTypeBulk,
 EndpointTypeInterrupt,
 EndpointTypeIsochronous
};
class CUSBEndpoint
{
public:
 CUSBEndpoint (CUSBDevice *pDevice);
 CUSBEndpoint (CUSBDevice *pDevice, const TUSBEndpointDescriptor *pDesc);
 ~CUSBEndpoint (void);
 CUSBDevice *GetDevice (void) const;
 u8 GetNumber (void) const;
 TEndpointType GetType (void) const;
 boolean IsDirectionIn (void) const;
 boolean SetMaxPacketSize (u32 nMaxPacketSize);
 u32 GetMaxPacketSize (void) const;
 void ResetPID (void);
 CXHCIEndpoint *GetXHCIEndpoint (void);
private:
 CUSBDevice *m_pDevice;
 u8 m_ucNumber;
 TEndpointType m_Type;
 boolean m_bDirectionIn;
 u32 m_nMaxPacketSize;
 CXHCIEndpoint *m_pXHCIEndpoint;
};
class CClassAllocator
{
public:
 CClassAllocator (size_t nObjectSize,
    unsigned nReservedObjects,
    const char *pClassName);
 CClassAllocator (size_t nObjectSize,
    unsigned nReservedObjects,
    unsigned nTargetLevel,
    const char *pClassName);
 ~CClassAllocator (void);
 void *Allocate (void);
 void Free (void *pBlock);
 void Extend (unsigned nReservedObjects, unsigned nTargetLevel);
private:
 void Init (size_t nObjectSize, unsigned nReservedObjects);
private:
 size_t m_nObjectSize;
 unsigned m_nReservedObjects;
 const char *m_pClassName;
 unsigned char *m_pMemory;
 struct TBlock *m_pFreeList;
 boolean m_bProtected;
 unsigned m_nTargetLevel;
 CSpinLock m_SpinLock;
};
class CUSBRequest;
typedef void TURBCompletionRoutine (CUSBRequest *pURB, void *pParam, void *pContext);
class CUSBRequest
{
public:
 static const unsigned MaxIsoPackets = 32;
public:
 CUSBRequest (CUSBEndpoint *pEndpoint, void *pBuffer, u32 nBufLen, TSetupData *pSetupData = 0);
 ~CUSBRequest (void);
 CUSBEndpoint *GetEndpoint (void) const;
 void SetStatus (int bStatus);
 void SetResultLen (u32 nLength);
 void SetUSBError (TUSBError Error);
 int GetStatus (void) const;
 u32 GetResultLength (void) const;
 TUSBError GetUSBError (void) const;
 TSetupData *GetSetupData (void);
 void *GetBuffer (void);
 u32 GetBufLen (void) const;
 void AddIsoPacket (u16 usPacketSize);
 unsigned GetNumIsoPackets (void) const;
 u16 GetIsoPacketSize (unsigned nPacketIndex) const;
 void SetCompletionRoutine (TURBCompletionRoutine *pRoutine, void *pParam, void *pContext);
 void CallCompletionRoutine (void);
 void SetCompleteOnNAK (void);
 boolean IsCompleteOnNAK (void) const;
private:
 CUSBEndpoint *m_pEndpoint;
 TSetupData *m_pSetupData;
 void *m_pBuffer;
 u32 m_nBufLen;
 int m_bStatus;
 u32 m_nResultLen;
 TUSBError m_USBError;
 unsigned m_nNumIsoPackets;
 u16 m_usIsoPacketSize[MaxIsoPackets];
 TURBCompletionRoutine *m_pCompletionRoutine;
 void *m_pCompletionParam;
 void *m_pCompletionContext;
 boolean m_bCompleteOnNAK;
 public: void *operator new (size_t nSize); void operator delete (void *pBlock, size_t nSize); static void InitAllocator (unsigned nReservedObjects); static void InitProtectedAllocator (unsigned nReservedObjects, unsigned nTargetLevel); private: static CClassAllocator *s_pAllocator;
};
class CUSBHCIRootPort;
class CUSBStandardHub;
class CUSBDevice;
class CUSBHostController : public CUSBController
{
public:
 CUSBHostController (boolean bPlugAndPlay);
 virtual ~CUSBHostController (void);
 int GetDescriptor (CUSBEndpoint *pEndpoint,
      unsigned char ucType, unsigned char ucIndex,
      void *pBuffer, unsigned nBufSize,
      unsigned char ucRequestType = 0x80,
      unsigned short wIndex = 0);
 boolean SetAddress (CUSBEndpoint *pEndpoint, u8 ucDeviceAddress);
 boolean SetConfiguration (CUSBEndpoint *pEndpoint, u8 ucConfigurationValue);
 int ControlMessage (CUSBEndpoint *pEndpoint,
       u8 ucRequestType, u8 ucRequest, u16 usValue, u16 usIndex,
       void *pData, u16 usDataSize);
 int Transfer (CUSBEndpoint *pEndpoint, void *pBuffer, unsigned nBufSize,
        unsigned nTimeoutMs = 0);
public:
 virtual boolean SubmitBlockingRequest (CUSBRequest *pURB,
            unsigned nTimeoutMs = 0) = 0;
 virtual boolean SubmitAsyncRequest (CUSBRequest *pURB,
         unsigned nTimeoutMs = 0) = 0;
 virtual void CancelDeviceTransactions (CUSBDevice *pUSBDevice) {}
public:
 boolean IsPlugAndPlay (void) const;
 boolean UpdatePlugAndPlay (void) override;
 static boolean IsActive (void)
 {
  return s_pThis != 0 ? true : false;
 }
 static CUSBHostController *Get (void);
protected:
 void PortStatusChanged (CUSBHCIRootPort *pRootPort);
 friend class CXHCIRootPort;
private:
 void PortStatusChanged (CUSBStandardHub *pHub);
 friend class CUSBStandardHub;
private:
 boolean m_bPlugAndPlay;
 boolean m_bFirstUpdateCall;
 CPtrList m_HubList;
 CSpinLock m_SpinLock;
 static CUSBHostController *s_pThis;
};
struct TXHCIBlockHeader
{
 u32 nMagic;
 u32 nSize;
 u32 nAlign;
 u32 nBoundary;
 TXHCIBlockHeader *pNext;
 u8 Data[0];
};
class CXHCISharedMemAllocator
{
public:
 CXHCISharedMemAllocator (uintptr nMemStart, uintptr nMemEnd);
 ~CXHCISharedMemAllocator (void);
 size_t GetFreeSpace (void) const;
 void *Allocate (size_t nSize, size_t nAlign, size_t nBoundary);
 void Free (void *pBlock);
private:
 uintptr m_nMemStart;
 uintptr m_nMemEnd;
 TXHCIBlockHeader *m_pFreeList;
};
class CXHCIDevice;
class CXHCIRootPort;
class CUSBStandardHub;
class CXHCIUSBDevice : public CUSBDevice
{
public:
 CXHCIUSBDevice (CXHCIDevice *pXHCIDevice, TUSBSpeed Speed, CXHCIRootPort *pRootPort);
 CXHCIUSBDevice (CXHCIDevice *pXHCIDevice, TUSBSpeed Speed,
   CUSBStandardHub *pHub, unsigned nHubPortIndex);
 ~CXHCIUSBDevice (void);
 boolean Initialize (void);
 boolean EnableHubFunction (void);
 u8 GetSlotID (void) const;
 TXHCIDeviceContext *GetDeviceContext (void);
 void RegisterEndpoint (u8 uchEndpointID, CXHCIEndpoint *pEndpoint);
 void TransferEvent (u8 uchCompletionCode, u32 nTransferLength, u8 uchEndpointID);
 void DumpStatus (void);
private:
 TXHCIInputContext *GetInputContextAddressDevice (void);
 TXHCIInputContext *GetInputContextEnableHubFunction (void);
 void FreeInputContext (void);
private:
 CXHCIDevice *m_pXHCIDevice;
 CXHCIRootPort *m_pRootPort;
 u8 m_uchSlotID;
 TXHCIDeviceContext *m_pDeviceContext;
 CXHCIEndpoint *m_pEndpoint[31];
 u8 *m_pInputContextBuffer;
};
class CXHCIDevice;
class CXHCISlotManager
{
public:
 CXHCISlotManager (CXHCIDevice *pXHCIDevice);
 ~CXHCISlotManager (void);
 boolean IsValid (void);
 void AssignDevice (u8 uchSlotID, CXHCIUSBDevice *pUSBDevice);
 void FreeSlot (u8 uchSlotID);
 void AssignScratchpadBufferArray (u64 *pScratchpadBufferArray);
 void DumpStatus (void);
private:
 void TransferEvent (u8 uchCompletionCode, u32 nTransferLength,
       u8 uchSlotID, u8 uchEndpointID);
 friend class CXHCIEventManager;
private:
 CXHCIDevice *m_pXHCIDevice;
 CXHCIMMIOSpace *m_pMMIO;
 u64 *m_pDCBAA;
 CXHCIUSBDevice *m_pUSBDevice[32];
};
class CXHCIDevice;
class CXHCIEventManager
{
public:
 CXHCIEventManager (CXHCIDevice *pXHCIDevice);
 ~CXHCIEventManager (void);
 boolean IsValid (void);
 TXHCITRB *HandleEvents (void);
 void DumpStatus (void);
private:
 CXHCIDevice *m_pXHCIDevice;
 CXHCIMMIOSpace *m_pMMIO;
 CXHCIRing m_EventRing;
 TXHCIERSTEntry *m_pERST;
};
class CXHCIDevice;
class CXHCICommandManager
{
public:
 CXHCICommandManager (CXHCIDevice *pXHCIDevice);
 ~CXHCICommandManager (void);
 boolean IsValid (void);
 int EnableSlot (u8 *pSlotID);
 int DisableSlot (u8 uchSlotID);
 int AddressDevice (u8 uchSlotID, TXHCIInputContext *pInputContext, boolean bSetAddress);
 int ConfigureEndpoint (u8 uchSlotID, TXHCIInputContext *pInputContext, boolean bDeconfigure);
 int EvaluateContext (u8 uchSlotID, TXHCIInputContext *pInputContext);
 int ResetEndpoint (u8 uchSlotID, u8 uchEndpointID);
 int SetTRDequeuePointer (u8 uchSlotID, u8 uchEndpointID, TXHCITRB *pTRB, boolean bDCS);
 int NoOp (void);
 void DumpStatus (void);
private:
 int DoCommand (u32 nControl,
         u32 nParameter1 = 0, u32 nParameter2 = 0, u32 nStatus = 0,
         u8 *pSlotID = 0);
 void CommandCompleted (TXHCITRB *pCommandTRB, u8 uchCompletionCode, u8 uchSlotID);
 friend class CXHCIEventManager;
private:
 CXHCIDevice *m_pXHCIDevice;
 CXHCIMMIOSpace *m_pMMIO;
 CXHCIRing m_CmdRing;
 volatile boolean m_bCommandCompleted;
 TXHCITRB *m_pCurrentCommandTRB;
 u8 m_uchCompletionCode;
 u8 m_uchSlotID;
};
class CUSBHCIRootPort
{
public:
 virtual ~CUSBHCIRootPort (void) {}
 virtual boolean ReScanDevices (void) = 0;
 virtual boolean RemoveDevice (void) = 0;
 virtual void HandlePortStatusChange (void) = 0;
 virtual u8 GetPortID (void) const = 0;
};
class CXHCIDevice;
class CXHCIRootPort : public CUSBHCIRootPort
{
public:
 CXHCIRootPort (u8 uchPortID, CXHCIDevice *pXHCIDevice);
 ~CXHCIRootPort (void);
 boolean Initialize (void);
 boolean Configure (void);
 u8 GetPortID (void) const;
 TUSBSpeed GetPortSpeed (void);
 boolean ReScanDevices (void);
 boolean RemoveDevice (void);
 void HandlePortStatusChange (void);
 void StatusChanged (void);
 void DumpStatus (void);
private:
 boolean IsConnected (void);
 boolean Reset (unsigned nTimeoutUsecs);
 boolean WaitForU0State (unsigned nTimeoutUsecs);
 boolean PowerOffOnOverCurrent (void);
private:
 unsigned m_nPortIndex;
 CXHCIDevice *m_pXHCIDevice;
 CXHCIMMIOSpace *m_pMMIO;
 CXHCIUSBDevice *m_pUSBDevice;
 CSpinLock m_SpinLock;
};
class CXHCIDevice;
class CXHCIRootHub
{
public:
 CXHCIRootHub (unsigned nPorts, CXHCIDevice *pXHCIDevice);
 ~CXHCIRootHub (void);
 boolean Initialize (void);
 boolean ReScanDevices (void);
 void DumpStatus (void);
private:
 void StatusChanged (u8 uchPortID);
 friend class CXHCIEventManager;
private:
 unsigned m_nPorts;
 CXHCIDevice *m_pXHCIDevice;
 CXHCIRootPort *m_pRootPort[5];
};
class CXHCIDevice : public CUSBHostController
{
public:
 CXHCIDevice (CInterruptSystem *pInterruptSystem, CTimer *pTimer,
       boolean bPlugAndPlay = false, unsigned nDevice = 0,
       CXHCISharedMemAllocator *pSharedMemAllocator = 0);
 ~CXHCIDevice (void);
 boolean Initialize (boolean bScanDevices = true);
 void ReScanDevices (void);
 boolean SubmitBlockingRequest (CUSBRequest *pURB, unsigned nTimeoutMs = 0);
 boolean SubmitAsyncRequest (CUSBRequest *pURB, unsigned nTimeoutMs = 0);
public:
 CXHCIMMIOSpace *GetMMIOSpace (void);
 CXHCISlotManager *GetSlotManager (void);
 CXHCICommandManager *GetCommandManager (void);
 CXHCIRootHub *GetRootHub (void);
 void *AllocateSharedMem (size_t nSize, size_t nAlign = 64,
     size_t nBoundary = (1 << 12));
 void FreeSharedMem (void *pBlock);
 void DumpStatus (void);
private:
 void InterruptHandler (void);
 static void InterruptStub (void *pParam);
 boolean HWReset (void);
private:
 CInterruptSystem *m_pInterruptSystem;
 boolean m_bInterruptConnected;
 unsigned m_nDevice;
 CBcmPCIeHostBridge m_PCIeHostBridge;
 CXHCISharedMemAllocator *m_pSharedMemAllocator;
 boolean m_bOwnSharedMemAllocator;
 CXHCIMMIOSpace *m_pMMIO;
 CXHCISlotManager *m_pSlotManager;
 CXHCIEventManager *m_pEventManager;
 CXHCICommandManager *m_pCommandManager;
 void *m_pScratchpadBuffers;
 u64 *m_pScratchpadBufferArray;
 CXHCIRootHub *m_pRootHub;
 boolean m_bShutdown;
};
void debug_hexdump (const void *pStart, unsigned nBytes, const char *pSource = 0);
void debug_stacktrace (const uintptr *pStackPtr, const char *pSource = 0);
static const char From[] = "xhciring";
CXHCIRing::CXHCIRing (TXHCIRingType Type, unsigned nTRBCount, CXHCIDevice *pAllocator)
: m_Type (Type),
 m_nTRBCount (nTRBCount),
 m_pAllocator (pAllocator),
 m_pFirstTRB (0),
 m_nEnqueueIndex (0),
 m_nDequeueIndex (0),
 m_nCycleState ((1 << 0))
{
 ( __builtin_expect (!!(m_nTRBCount >= 16), 1) ? ((void) 0) : assertion_failed ("m_nTRBCount >= 16", "xhciring.cpp", 37));
 ( __builtin_expect (!!(m_nTRBCount % 4 == 0), 1) ? ((void) 0) : assertion_failed ("m_nTRBCount % 4 == 0", "xhciring.cpp", 38));
 ( __builtin_expect (!!(m_pAllocator != 0), 1) ? ((void) 0) : assertion_failed ("m_pAllocator != 0", "xhciring.cpp", 40));
 m_pFirstTRB = (TXHCITRB *) m_pAllocator->AllocateSharedMem (m_nTRBCount * sizeof (TXHCITRB),
            64, 0x10000);
 if (m_pFirstTRB == 0)
 {
  return;
 }
 if (m_Type != XHCIRingTypeEvent)
 {
  TXHCITRB *pLinkTRB = &m_pFirstTRB[m_nTRBCount - 1];
  pLinkTRB->Parameter = ((u64) (uintptr) (m_pFirstTRB) | CBcmPCIeHostBridge::GetDMAAddress ());
  pLinkTRB->Status = 0;
  pLinkTRB->Control = 6 << 10
        | (1 << 1);
 }
}
CXHCIRing::~CXHCIRing (void)
{
 if (m_pFirstTRB != 0)
 {
  m_pAllocator->FreeSharedMem (m_pFirstTRB);
  m_pFirstTRB = 0;
 }
}
boolean CXHCIRing::IsValid (void) const
{
 return m_pFirstTRB != 0;
}
unsigned CXHCIRing::GetTRBCount (void) const
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 76));
 return m_nTRBCount;
}
TXHCITRB *CXHCIRing::GetFirstTRB (void)
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 83));
 return m_pFirstTRB;
}
TXHCITRB *CXHCIRing::GetDequeueTRB (void)
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 90));
 ( __builtin_expect (!!(m_nDequeueIndex < m_nTRBCount), 1) ? ((void) 0) : assertion_failed ("m_nDequeueIndex < m_nTRBCount", "xhciring.cpp", 91));
 if ((m_pFirstTRB[m_nDequeueIndex].Control & (1 << 0)) != m_nCycleState)
 {
  return 0;
 }
 return &m_pFirstTRB[m_nDequeueIndex];
}
TXHCITRB *CXHCIRing::GetEnqueueTRB (void)
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 103));
 ( __builtin_expect (!!(m_nEnqueueIndex < m_nTRBCount), 1) ? ((void) 0) : assertion_failed ("m_nEnqueueIndex < m_nTRBCount", "xhciring.cpp", 104));
 if ((m_pFirstTRB[m_nEnqueueIndex].Control & (1 << 0)) == m_nCycleState)
 {
  return 0;
 }
 return &m_pFirstTRB[m_nEnqueueIndex];
}
TXHCITRB *CXHCIRing::IncrementDequeue (void)
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 116));
 ( __builtin_expect (!!(m_Type == XHCIRingTypeEvent), 1) ? ((void) 0) : assertion_failed ("m_Type == XHCIRingTypeEvent", "xhciring.cpp", 117));
 ( __builtin_expect (!!(m_nDequeueIndex < m_nTRBCount), 1) ? ((void) 0) : assertion_failed ("m_nDequeueIndex < m_nTRBCount", "xhciring.cpp", 118));
 ( __builtin_expect (!!((m_pFirstTRB[m_nDequeueIndex].Control & (1 << 0)) == m_nCycleState), 1) ? ((void) 0) : assertion_failed ("(m_pFirstTRB[m_nDequeueIndex].Control & XHCI_TRB_CONTROL_C) == m_nCycleState", "xhciring.cpp", 120));
 if (++m_nDequeueIndex == m_nTRBCount)
 {
  m_nDequeueIndex = 0;
  m_nCycleState ^= (1 << 0);
 }
 return &m_pFirstTRB[m_nDequeueIndex];
}
void CXHCIRing::IncrementEnqueue (void)
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 135));
 ( __builtin_expect (!!(m_Type != XHCIRingTypeEvent), 1) ? ((void) 0) : assertion_failed ("m_Type != XHCIRingTypeEvent", "xhciring.cpp", 136));
 ( __builtin_expect (!!(m_nEnqueueIndex < m_nTRBCount), 1) ? ((void) 0) : assertion_failed ("m_nEnqueueIndex < m_nTRBCount", "xhciring.cpp", 137));
 ( __builtin_expect (!!((m_pFirstTRB[m_nEnqueueIndex].Control & (1 << 0)) == m_nCycleState), 1) ? ((void) 0) : assertion_failed ("(m_pFirstTRB[m_nEnqueueIndex].Control & XHCI_TRB_CONTROL_C) == m_nCycleState", "xhciring.cpp", 139));
 if (++m_nEnqueueIndex == m_nTRBCount-1)
 {
  TXHCITRB *pLinkTRB = &m_pFirstTRB[m_nEnqueueIndex];
  pLinkTRB->Control ^= (1 << 0);
  if (pLinkTRB->Control & (1 << 1))
  {
   m_nCycleState ^= (1 << 0);
  }
  m_nEnqueueIndex = 0;
 }
}
u32 CXHCIRing::GetCycleState (void) const
{
 ( __builtin_expect (!!(m_pFirstTRB != 0), 1) ? ((void) 0) : assertion_failed ("m_pFirstTRB != 0", "xhciring.cpp", 159));
 return m_nCycleState;
}
void CXHCIRing::DumpStatus (const char *pFrom)
{
 CLogger::Get ()->Write (pFrom != 0 ? pFrom : From, LogDebug, "Count %u, %s %u, Cycle %u",
    m_nTRBCount,
    m_Type == XHCIRingTypeEvent ? "Dequeue" : "Enqueue",
    m_Type == XHCIRingTypeEvent ? m_nDequeueIndex : m_nEnqueueIndex,
    m_nCycleState);
 if (m_pFirstTRB != 0)
 {
  debug_hexdump (m_pFirstTRB, m_nTRBCount * sizeof (TXHCITRB),
          pFrom != 0 ? pFrom : From);
 }
}
