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
struct TARMV8MMU_LEVEL2_TABLE_DESCRIPTOR
{
 u64 Value11 : 2,
  Ignored1 : 14,
  TableAddress : 32,
  Reserved0 : 4,
  Ignored2 : 7,
  PXNTable : 1,
  UXNTable : 1,
  APTable : 2,
  NSTable : 1;
}
__attribute__ ((packed));
struct TARMV8MMU_LEVEL2_BLOCK_DESCRIPTOR
{
 u64 Value01 : 2,
   AttrIndx : 3,
   NS : 1,
   AP : 2,
   SH : 2,
   AF : 1,
   nG : 1,
  Reserved0_1 : 17,
  OutputAddress : 19,
  Reserved0_2 : 4,
   Continous : 1,
   PXN : 1,
   UXN : 1,
   Ignored : 9;
}
__attribute__ ((packed));
struct TARMV8MMU_LEVEL2_INVALID_DESCRIPTOR
{
 u64 Value0 : 1,
  Ignored : 63;
}
__attribute__ ((packed));
union TARMV8MMU_LEVEL2_DESCRIPTOR
{
 TARMV8MMU_LEVEL2_TABLE_DESCRIPTOR Table;
 TARMV8MMU_LEVEL2_BLOCK_DESCRIPTOR Block;
 TARMV8MMU_LEVEL2_INVALID_DESCRIPTOR Invalid;
}
__attribute__ ((packed));
struct TARMV8MMU_LEVEL3_PAGE_DESCRIPTOR
{
 u64 Value11 : 2,
   AttrIndx : 3,
   NS : 1,
   AP : 2,
   SH : 2,
   AF : 1,
   nG : 1,
  Reserved0_1 : 4,
  OutputAddress : 32,
  Reserved0_2 : 4,
   Continous : 1,
   PXN : 1,
   UXN : 1,
   Ignored : 9
  ;
}
__attribute__ ((packed));
struct TARMV8MMU_LEVEL3_INVALID_DESCRIPTOR
{
 u64 Value0 : 1,
  Ignored : 63;
}
__attribute__ ((packed));
union TARMV8MMU_LEVEL3_DESCRIPTOR
{
 TARMV8MMU_LEVEL3_PAGE_DESCRIPTOR Page;
 TARMV8MMU_LEVEL3_INVALID_DESCRIPTOR Invalid;
}
__attribute__ ((packed));
class CTranslationTable
{
public:
 CTranslationTable (size_t nMemSize) __attribute__ ((optimize (0)));
 ~CTranslationTable (void);
 uintptr GetBaseAddress (void) const;
private:
 TARMV8MMU_LEVEL3_DESCRIPTOR *CreateLevel3Table (uintptr nBaseAddress) __attribute__ ((optimize (0)));
private:
 size_t m_nMemSize;
 TARMV8MMU_LEVEL2_DESCRIPTOR *m_pTable;
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
extern "C" {
void *malloc (size_t nSize);
void *memalign (size_t nAlign, size_t nSize);
void free (void *pBlock);
void *calloc (size_t nBlocks, size_t nSize);
void *realloc (void *pBlock, size_t nSize);
void *palloc (void);
void pfree (void *pPage);
}
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
 static CLogger *s_pThis;
};
extern "C" {
void *memset (void *pBuffer, int nValue, size_t nLength);
void *memcpy (void *pDest, const void *pSrc, size_t nLength);
void *memmove (void *pDest, const void *pSrc, size_t nLength);
int memcmp (const void *pBuffer1, const void *pBuffer2, size_t nLength);
size_t strlen (const char *pString);
int strcmp (const char *pString1, const char *pString2);
int strcasecmp (const char *pString1, const char *pString2);
int strncmp (const char *pString1, const char *pString2, size_t nMaxLen);
int strncasecmp (const char *pString1, const char *pString2, size_t nMaxLen);
char *strcpy (char *pDest, const char *pSrc);
char *strncpy (char *pDest, const char *pSrc, size_t nMaxLen);
char *strcat (char *pDest, const char *pSrc);
char *strncat (char *pDest, const char *pSrc, size_t nMaxLen);
char *strchr (const char *pString, int chChar);
char *strstr (const char *pString, const char *pNeedle);
char *strtok_r (char *pString, const char *pDelim, char **ppSavePtr);
unsigned long strtoul (const char *pString, char **ppEndPtr, int nBase);
unsigned long long strtoull (const char *pString, char **ppEndPtr, int nBase);
int atoi (const char *pString);
int char2int (char chValue);
}
CTranslationTable::CTranslationTable (size_t nMemSize)
: m_nMemSize (nMemSize),
 m_pTable (0)
{
 m_pTable = (TARMV8MMU_LEVEL2_DESCRIPTOR *) palloc ();
 ( __builtin_expect (!!(m_pTable != 0), 1) ? ((void) 0) : assertion_failed ("m_pTable != 0", "translationtable64.cpp", 52));
 memset (m_pTable, 0, 0x10000);
 for (unsigned nEntry = 0; nEntry < 128; nEntry++)
 {
  u64 nBaseAddress = (u64) nEntry * 8192 * 0x10000;
  if ( nBaseAddress >= 4*0x40000000UL
      && !( 0x600000000UL <= nBaseAddress
    && nBaseAddress <= (0x600000000UL + 0x4000000UL - 1UL)))
  {
   continue;
  }
  TARMV8MMU_LEVEL3_DESCRIPTOR *pTable = CreateLevel3Table (nBaseAddress);
  ( __builtin_expect (!!(pTable != 0), 1) ? ((void) 0) : assertion_failed ("pTable != 0", "translationtable64.cpp", 78));
  TARMV8MMU_LEVEL2_TABLE_DESCRIPTOR *pDesc = &m_pTable[nEntry].Table;
  pDesc->Value11 = 3;
  pDesc->Ignored1 = 0;
  pDesc->TableAddress = ((((u64) pTable) >> 16) & 0xFFFFFFFF);
  pDesc->Reserved0 = 0;
  pDesc->Ignored2 = 0;
  pDesc->PXNTable = 0;
  pDesc->UXNTable = 0;
  pDesc->APTable = 0;
  pDesc->NSTable = 0;
  u64 rawValue = *reinterpret_cast<u64 *>(pDesc);
  CLogger::Get()->Write("mmu", LogNotice, "MMU Level 2 Descriptor Address: 0x%p, Value: 0x%016lx",
                          pDesc, rawValue);
 }
 asm volatile ("dsb sy" ::: "memory");
}
CTranslationTable::~CTranslationTable (void)
{
 pfree (m_pTable);
 m_pTable = 0;
}
uintptr CTranslationTable::GetBaseAddress (void) const
{
 ( __builtin_expect (!!(m_pTable != 0), 1) ? ((void) 0) : assertion_failed ("m_pTable != 0", "translationtable64.cpp", 108));
 return (uintptr) m_pTable;
}
TARMV8MMU_LEVEL3_DESCRIPTOR *CTranslationTable::CreateLevel3Table (uintptr nBaseAddress)
{
 TARMV8MMU_LEVEL3_DESCRIPTOR *pTable = (TARMV8MMU_LEVEL3_DESCRIPTOR *) palloc ();
 ( __builtin_expect (!!(pTable != 0), 1) ? ((void) 0) : assertion_failed ("pTable != 0", "translationtable64.cpp", 115));
 for (unsigned nPage = 0; nPage < 8192; nPage++)
 {
  TARMV8MMU_LEVEL3_PAGE_DESCRIPTOR *pDesc = &pTable[nPage].Page;
  pDesc->Value11 = 3;
  pDesc->AttrIndx = 0;
  pDesc->NS = 0;
  pDesc->AP = 0;
  pDesc->SH = 3;
  pDesc->AF = 1;
  pDesc->nG = 0;
  pDesc->Reserved0_1 = 0;
  pDesc->OutputAddress = (((nBaseAddress) >> 16) & 0xFFFFFFFF);
  pDesc->Reserved0_2 = 0;
  pDesc->Continous = 0;
  pDesc->PXN = 0;
  pDesc->UXN = 1;
  pDesc->Ignored = 0;
  extern u8 _etext;
  if (nBaseAddress >= (u64) &_etext)
  {
   pDesc->PXN = 1;
   if ( ( nBaseAddress >= m_nMemSize
           && nBaseAddress < 0x40000000UL)
       || nBaseAddress > (3 * 0x40000000UL - 1))
   {
    pDesc->AttrIndx = 1;
    pDesc->SH = 2;
   }
   else if ( nBaseAddress >= ((((((0x80000 + (2 * 0x100000)) + 0x20000) + 0x20000 * (4 -1) + 0x8000) + 0x8000 * (4 -1)) + 2*0x100000) & ~(0x100000 -1))
     && nBaseAddress < (((((((0x80000 + (2 * 0x100000)) + 0x20000) + 0x20000 * (4 -1) + 0x8000) + 0x8000 * (4 -1)) + 2*0x100000) & ~(0x100000 -1)) + 4*0x100000))
   {
    pDesc->AttrIndx = 2;
    pDesc->SH = 2;
   }
  }
  nBaseAddress += 0x10000;
  u64 rawValue = *reinterpret_cast<u64 *>(pDesc);
  CLogger::Get()->Write("mmu", LogNotice, "MMU Level 3 Descriptor Address: 0x%p, Value: 0x%016lx",
                          pDesc, rawValue);
 }
 return pTable;
}
