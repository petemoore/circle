#include "kernel.h"
#include <circle/util.h>

static const char FromKernel[] = "kernel";
static const size_t bufferSize = 0x8000;

CKernel *CKernel::s_pThis = 0;

CKernel::CKernel (void)
:
	m_Screen (m_Options.GetWidth (), m_Options.GetHeight ()),
	m_Timer (&m_Interrupt),
	m_Logger (m_Options.GetLogLevel (), &m_Timer)
{
	s_pThis = this;

	m_ActLED.Blink (5);	// show we are alive
}

CKernel::~CKernel (void)
{
	s_pThis = 0;
}

boolean CKernel::Initialize (void)
{
	boolean bOK = TRUE;

	if (bOK)
	{
		bOK = m_Screen.Initialize ();
	}

	if (bOK)
	{
		bOK = m_Serial.Initialize (115200);
	}

	if (bOK)
	{
		CDevice *pTarget = m_DeviceNameService.GetDevice (m_Options.GetLogDevice (), FALSE);
		if (pTarget == 0)
		{
			pTarget = &m_Screen;
		}

		bOK = m_Logger.Initialize (pTarget);
	}

	if (bOK)
	{
		bOK = m_Interrupt.Initialize ();
	}

	if (bOK)
	{
		bOK = m_Timer.Initialize ();
	}

	return bOK;
}

unsigned int BenchmarkMemset(const char* label, unsigned int iterations, void* (*memsetFunc)(void*, int, size_t), void* mem, int value, size_t length, CTimer& timer, CLogger& logger)
{
	unsigned int nMicroSec = timer.GetClockTicks64 ();
	for (unsigned int count = 0; count < iterations; count++)
	{
		memsetFunc(mem, value, length);
		count++;
	}
	unsigned int durationMicroSec = timer.GetClockTicks64 () - nMicroSec;
	logger.Write(FromKernel, LogNotice, "Benchmark result (%s): %u calls in %u microseconds", label, iterations, durationMicroSec);
	return durationMicroSec;
}

void CompareMemsetFuncs(const char* label1, const char* label2, void* (*memsetFunc1)(void*, int, size_t), void* (*memsetFunc2)(void*, int, size_t), unsigned int compareIterations, unsigned int benchmarkIterations, CTimer& timer, CLogger& logger, CBcmRandomNumberGenerator random)
{
	static unsigned char buffer1[bufferSize] = {0}; // Initialized to zeros
	static unsigned char buffer2[bufferSize] = {0}; // Initialized to zeros

	unsigned int totalMicroSec1 = 0;
	unsigned int totalMicroSec2 = 0;

	for (unsigned int iteration = 0; iteration < compareIterations; iteration++) {
		/* Generate random offset (0 to bufferSize) and random length (0 to fit within the buffer) */
		size_t offset = random.GetNumber () % (bufferSize + 1); // Offset between 0 and bufferSize
		size_t maxLength = bufferSize - offset;
		size_t length = random.GetNumber () % (maxLength + 1); // Generates length between 0 and maxLength

		/* Allowing values > 255 provides additional test coverage */
		int value = random.GetNumber ();

		/* Perform memset on buffer1 */
		logger.Write (FromKernel, LogError, "Calling %s (0x%x, 0x%x, 0x%x)", label1, buffer1 + offset, value, length);
		memsetFunc1 (buffer1 + offset, value, length);

		/* Perform memset on buffer2 */
		logger.Write (FromKernel, LogError, "Calling %s (0x%x, 0x%x, 0x%x)", label2, buffer2 + offset, value, length);
		memsetFunc2 (buffer2 + offset, value, length);

		logger.Write (FromKernel, LogNotice, "Comparing results of %s and %s...", label1, label2);

		/* Compare buffers */
		bool identical = true;
		for (size_t i = 0; i < bufferSize; i++) {
			if (buffer1[i] != buffer2[i]) {
				identical = false;
				logger.Write(FromKernel, LogError, "Buffer mismatch: buffer1[0x%x] = 0x%02x, buffer2[0x%x] = 0x%02x, buffer1 address = 0x%x, buffer2 address = 0x%x, size = 0x%x, offset = 0x%x, value = 0x%x, length = 0x%x", i, buffer1[i], i, buffer2[i], (void*)buffer1, (void*)buffer2, bufferSize, offset, value, length);
				break;
			}
		}

		if (!identical) {
			logger.Write(FromKernel, LogError, "Buffers do not match! Exiting test.");
			return;
		}

		logger.Write(FromKernel, LogError, "Buffers match.");

		/* Benchmark both implementations using buffer1 to ensure fairness (buffer1 and buffer2 may be aligned differently) */
		totalMicroSec1 += BenchmarkMemset(label1, benchmarkIterations, memsetFunc1, buffer1 + offset, value, length, timer, logger);
		totalMicroSec2 += BenchmarkMemset(label2, benchmarkIterations, memsetFunc2, buffer1 + offset, value, length, timer, logger);
	}

	logger.Write(FromKernel, LogNotice, "All tests completed. %s total time: %d microseconds, %s total time: %d microseconds", label1, totalMicroSec1, label2, totalMicroSec2);
}

TShutdownMode CKernel::Run (void)
{
	CompareMemsetFuncs("memset", "memset2", memset, memset2, 100, 20000, m_Timer, m_Logger, m_Random);
	return ShutdownNone;
}
