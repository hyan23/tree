// mkfont.cpp
// Author: hyan23
// Date: 2016.07.30
//

#include <stdio.h>

int main(void) {
	unsigned int counter = 0;
	char szname[20] = { '\0' }, szbuf[20] = { '\0' };
	FILE *fin = NULL, *fout = NULL;

	fin = fopen("hankaku.txt", "r");
	fout = fopen("fontdata.txt", "w");

	if (NULL == fin || NULL == fout) {
		printf("file open error\n");
		goto fin;
	}

	while (!feof(fin)) {
		if (!fgets(szbuf, 20, fin)) {
			continue;
		}
		if ('c' == *szbuf || '\n' == *szbuf) {
			continue;
		}

		szbuf[8] = '\'';
		if (0 == counter % 16) {
			fprintf(fout, "\n\n; char 0x%02x\n\n", counter);
		}
		fprintf(fout, "DB \'%s\n", szbuf);

		printf("%s", szbuf);
		counter ++;
	}

fin:
	if (NULL != fin) {
		fclose(fin);
	}
	if (NULL != fout) {
		fclose(fout);
	}

	getchar();

	return 0;
}
