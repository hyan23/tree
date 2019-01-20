// selector_helper.c
// Author: hyan23
// Date: 2017.08.31

#include <stdio.h>

int main(void)
{
    FILE *fin = fopen("selector.txt", "r");
    FILE *fout = fopen("selector1.txt", "w");
    
    if (fin == NULL || fout == NULL)
    {
        if (fin != NULL)
            fclose(fin);
        if (fout != NULL)
            fclose(fout);
        fprintf(stderr, "File open error.\n");
        return -1;
    }
    
    char buf[100], buf1[100];
    while (fscanf(fin, "%s%s%s", buf, buf1, buf1) == 3)
    {
        fprintf(fout, "%-24sEQU\t\t%s\n", buf, buf1);
    }
    
    fclose(fin);
    fclose(fout);
    return 0;
}
