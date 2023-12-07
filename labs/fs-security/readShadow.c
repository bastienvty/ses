#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>



int main()
{
FILE *pFile;
char line [128];
char *p="";

    pFile = fopen ("/etc/shadow", "r");
    if (pFile)
    {
        memset (&line[0], 0, sizeof(line));
        for (;fgets (&line[0], sizeof(line)-1, pFile);)
        {
            printf ("%s", &line[0]);
            memset (&line[0], 0, sizeof(line));
        }
        fclose (pFile);
    }
    else
        printf ("Can not open the /etc/shadow file\n");
    
    //execl("./setuid_test", "./setuid_test", NULL);
    return 0;
}
