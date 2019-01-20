// fixvhdwr.cpp
// Author: hyan23
// Date: 2016.04.30
//

#include "stdafx.h"
#include "vhd_ftr.h"
#include <time.h>
#include <Windows.h>

#define FIXVHDWR_BLOCK_LEN 512
#define FIXVHDWR_USAGE "磁盘文件 数据文件 扇区号(不大于10000)"

BOOL CreateVirtDisk(LPCSTR szFile, DWORD dwSizeInByte, VHD_FTR vhdftr);

#define OPEN_VIRT_DISK_RET			DWORD
#define OPEN_VIRT_DISK_RET_SUCCESS	0
#define OPEN_VIRT_DISK_RET_FAILED	-1
#define OPEN_VIRT_DISK_RET_INVALID	-2

OPEN_VIRT_DISK_RET OpenVirtDisk(LPCSTR szFile, FILE** _File, PVHD_FTR pvhdftr);

void CloseVirtDisk(FILE* _File);
void ShowVirtDiskInfo(VHD_FTR vhdftr);
DWORD WriteVirtDisk(FILE* vhd, FILE* data, DWORD dwSector);

BOOL S2I(LPCSTR szI, DWORD& dwI); // 不大于五位数

int main(int argc, char* argv[]) {
	DWORD dwSector = 0;
	CHAR szVHDFile[MAX_PATH ] = { '\0' };
	CHAR szDataFile[MAX_PATH ] = { '\0' };

#pragma warning(disable:4996)
	if (1 == argc) {
		printf("请输入: %s:\n", FIXVHDWR_USAGE);
		scanf("%s%s%d", szVHDFile, szDataFile, &dwSector);
		if (0 < dwSector / 10000) {
			printf("参数错误!\n");
			goto __FINISH;
		}
	} else if (4 != argc && 5 != argc) {
		printf("使用方法: fixvhdwr %s。\n", FIXVHDWR_USAGE);
		goto __FINISH;
	} else {
		strcpy_s(szVHDFile, argv[1]);
		strcpy_s(szDataFile, argv[2]);
		if (TRUE != S2I(argv[3], dwSector)) {
			printf("参数错误!\n");
			goto __FINISH;
		}
	}

	FILE* vhd = NULL, *data = NULL;
	VHD_FTR vhdftr;

	ZeroMemory(&vhdftr, VHD_FTR_SIZE);

	OPEN_VIRT_DISK_RET open = OPEN_VIRT_DISK_RET_SUCCESS;

	open = OpenVirtDisk(szVHDFile, &vhd, &vhdftr);

	if (OPEN_VIRT_DISK_RET_SUCCESS != open) {
		printf("文件 %s 不可读或不是一个有效的 vhd 文件!\n", szVHDFile);
		goto __END;
	} else {
		printf("文件 %s 打开成功! 信息如下:\n", szVHDFile);
		ShowVirtDiskInfo(vhdftr);
	}

	fopen_s(&data, szDataFile, "rb");
	if (NULL == data) {
		printf("数据文件 %s 打开失败!\n", szDataFile);
		goto __END;
	} else {
		printf("数据文件 %s 打开成功!\n", szDataFile);
	}

	printf("开始写入...\n");
	printf(
		"成功, 影响了从 %d 开始的 %d 个扇区。\n",
		dwSector, WriteVirtDisk(vhd, data, dwSector)
	);

__END:
	CloseVirtDisk(vhd);
	if (NULL != data) {
		fclose(data);
		data = NULL;
	}

__FINISH:
	if (5 != argc) {
		system("pause");
	}

	return 0;
}

BOOL CreateVirtDisk(LPCSTR szFile, DWORD dwSize, VHD_FTR vhdftr) {
	return TRUE;
}

OPEN_VIRT_DISK_RET OpenVirtDisk(LPCSTR szFile, FILE** _File, PVHD_FTR pvhdftr) {
	fopen_s(_File, szFile, "rb+");

	if (NULL == *_File) {
		return OPEN_VIRT_DISK_RET_FAILED;
	}

	if (0 != fseek(*_File, - (INT) (VHD_FTR_SIZE), SEEK_END)) {
		return OPEN_VIRT_DISK_RET_INVALID;
	}

	DWORD dwTotalRead = 0;

	dwTotalRead = fread_s(pvhdftr, VHD_FTR_SIZE, 1, VHD_FTR_SIZE, *_File);

	if (VHD_FTR_SIZE != dwTotalRead) {
		return OPEN_VIRT_DISK_RET_INVALID;
	}

	if (0 != strcmp("conectix", pvhdftr->cookie)) {
		return OPEN_VIRT_DISK_RET_INVALID;
	}

	return OPEN_VIRT_DISK_RET_SUCCESS;
}

void ShowVirtDiskInfo(VHD_FTR vhdftr) {
	tm loacltime;
	time_t create_time = 0;

	create_time = 0xb492f400 + vhdftr.timestamp;
	gmtime_s(&loacltime, &create_time);

	printf("创建者标识: %s\n", vhdftr.cookie);
	printf("创建时间: %s", asctime(&loacltime));
	printf("创建容量: %lu 字节\n", vhdftr.orig_size);
	printf("创建应用程序: %s\n", vhdftr.crtr_app);
	printf("应用程序版本: %d\n", vhdftr.crtr_ver);
	printf("操作系统: %d\n", vhdftr.crtr_os);
	printf("检验码: %X\n", vhdftr.checksum);
	switch (vhdftr.type) {
	case HD_TYPE_FIXED : {
		printf("硬盘类型: 固定分配\n");
		break;
						 }
	case HD_TYPE_DYNAMIC: {
		printf("硬盘类型: 动态分配\n");
		break;
						  }
	case HD_TYPE_DIFF: {
		printf("硬盘类型: 差分\n");
		break;
					   }
	default: {
		printf("未知硬盘类型\n");
		break;
					   }
	}
}

void CloseVirtDisk(FILE* _File) {
	if (NULL != _File) {
		fclose(_File);
		_File = NULL;
	}
}

DWORD WriteVirtDisk(FILE* vhd, FILE* data, DWORD dwSector) {
	DWORD dwTotalRead = 0, dwSectorInvolved = 0;
	BYTE pBuffer[FIXVHDWR_BLOCK_LEN ] = { 0 };

	printf("fseek: %d.\n", fseek(vhd, 512 * dwSector, SEEK_SET));
	printf("fteel: %ld.\n", ftell(vhd));

	while (!feof(data)) {
		dwTotalRead = fread(pBuffer, 1, FIXVHDWR_BLOCK_LEN, data);
		printf("%d ", dwTotalRead);
		fwrite(pBuffer, 1, dwTotalRead, vhd);
		dwSectorInvolved ++;
	}

	printf("\n");
	return dwSectorInvolved - 1;
}

BOOL S2I(LPCSTR szI, DWORD& dwI) {
	INT iLen = 0;

	dwI = 0;
	iLen = strlen(szI);

	if (5 < iLen) {
		return FALSE;
	}

	for (int i = 0; i < iLen; i ++) {
		if (!('0' <= szI[i] && '9' >= szI[i])) {
			return FALSE;
		}
	}

	INT iWeight = 1;
	INT iCursor = iLen - 1;

	for (; iCursor >= 0; iCursor --) {
		dwI += iWeight * (szI[iCursor] - '0');
		iWeight *= 10;
	}

	return TRUE;
}
