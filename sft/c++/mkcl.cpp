// mkcl.cpp
// Author: hyan23
// Date: 2016.07.27
//

#include <stdio.h>

int main(void) {
	unsigned int r = 0, g = 0, b = 0, counter = 0;
	char szclname[20] = { '\0' }, szbuf[20] = { '\0' };
	FILE *fin = NULL, *fout = NULL;
	FILE* foutselector = NULL;

	fin = fopen("rgb.txt", "r");
	fout = fopen("palette256.txt", "w");
	foutselector = fopen("selector.txt", "w");

	if (NULL == fin || NULL == fout || NULL == foutselector) {
		printf("file open error\n");
		goto fin;
	}

	while (!feof(fin)) {
		if (!fscanf(fin, "%s%d%d%d%s", szclname, &r, &g, &b, szbuf)) {
			continue;
		}
		printf("%s %d %d %d %s\n", szclname, r, g, b, szbuf);
		fprintf(fout, "%s DB %d, %d, %d\n", szclname, r, g, b);
		fprintf(foutselector, "Color_%s\t\tEQU\t\t%d\n", szclname, counter);
		counter ++;
	}

fin:
	if (NULL != fin) {
		fclose(fin);
	}
	if (NULL != fout) {
		fclose(fout);
	}
	if (NULL != foutselector) {
		fclose(foutselector);
	}

	getchar();

	return 0;
}
