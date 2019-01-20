// vhd_ftr.h
// Author: hyan23
// Date: 2015.05.01
//

#include <Windows.h>
#include <BaseTsd.h>

#pragma once

#define HD_TYPE_NONE		0
#define HD_TYPE_FIXED		2	/* Fixed-Allocation Disk */
#define HD_TYPE_DYNAMIC		3	/* Dynamic Disk */
#define HD_TYPE_DIFF		4	/* Differencing Disk */

#define HD_NO_FEATURES		0x00000000
#define HD_TEMPORARY		0x00000001	/* Disk Can Be Deleted On Shutdown */
#define HD_RESERVED			0x00000002	/* NOTE: Must Always Be Set */

typedef struct _VHD_FTR {

	CHAR		cookie[8];		/* Identifies Original Creator Of The Disk */
	UINT32		features;		/* Feature Support -- See Below */
	UINT32		ff_version;		/* (Major, Minor) Version Of Disk File */
	UINT64		data_offset;	/* Absolute. Offset From SOF To Next Structure */
	UINT32		timestamp;		/* Creation Time. Secs Since 1/1/2000GMT */
	CHAR		crtr_app[4];	/* Creator Application */
	UINT32		crtr_ver;		/* Creator Version (major, minor) */
	UINT32		crtr_os;		/* Creator Host OS */
	UINT64		orig_size;		/* Size At Creation (bytes) */
	UINT64		curr_size;		/* Current Size Of Disk (Bytes) */
	UINT32		geometry;		/* Disk Geometry */
	UINT32		type;			/* Disk Type */
	UINT32		checksum;		/* 1's Comp Sum Of This Struct. */
	CHAR		uid[16];		/* Unique Disk ID, Used For Naming Parents */
	CHAR		saved;			/* One-Bit -- Is This Disk/VM In A Saved State? */
	CHAR		hidden;			/* Tapdisk-Specific Field: Is This Vdi Hidden? */
	CHAR		reserved[426];	/* Padding */

} VHD_FTR, *PVHD_FTR;

#define VHD_FTR_SIZE sizeof (VHD_FTR)
