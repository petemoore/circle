//
/// \file memio.h
//
// Circle - A C++ bare metal environment for Raspberry Pi
// Copyright (C) 2014-2021  R. Stange <rsta2@o2online.de>
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
#ifndef _circle_memio_h
#define _circle_memio_h

#include <circle/types.h>
#include <circle/logger.h>

#ifdef __cplusplus
extern "C" {
#endif

/// \brief Read 8-bit value from MMIO address
static inline u8 read8 (uintptr nAddress)
{
	u8 result;
	result = *(u8 volatile *) nAddress;
	LOGNOTE ("read8 [%x] = %x", result);
	return result;
}

/// \brief Write 8-bit value to MMIO address
static inline void write8 (uintptr nAddress, u8 uchValue)
{
	LOGNOTE ("write8 [%x] = %x", nAddress, uchValue);
	*(u8 volatile *) nAddress = uchValue;
}

/// \brief Read 16-bit value from MMIO address
static inline u16 read16 (uintptr nAddress)
{
	u16 result;
	result = *(u16 volatile *) nAddress;
	LOGNOTE ("read16 [%x] = %x", nAddress, result);
	return result;
}

/// \brief Write 16-bit value to MMIO address
static inline void write16 (uintptr nAddress, u16 usValue)
{
	LOGNOTE ("write16 [%x] = %x", nAddress, usValue);
	*(u16 volatile *) nAddress = usValue;
}

/// \brief Read 32-bit value from MMIO address
static inline u32 read32 (uintptr nAddress)
{
	u32 result;
    result = *(u32 volatile *) nAddress;
	LOGNOTE ("read32 [%x] = %x", nAddress, result);
	return result;
}

/// \brief Write 32-bit value to MMIO address
static inline void write32 (uintptr nAddress, u32 nValue)
{
	LOGNOTE ("write32 [%x] = %x", nAddress, nValue);
	*(u32 volatile *) nAddress = nValue;
}

#ifdef __cplusplus
}
#endif

#endif
