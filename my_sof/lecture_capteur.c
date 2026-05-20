#include <stdio.h>
#include "system.h"
#include "io.h"

int main()
{
    int data0;
    int ready;

    // seuil = 104
    IOWR(CAPTEURS_SOL_SEUIL_BASE, 1, 104);

    while(1)
    {
        // lecture READY + vecteur
        ready = IORD(CAPTEURS_SOL_SEUIL_BASE, 0);

        // lecture capteur 0
        data0 = IORD(CAPTEURS_SOL_SEUIL_BASE, 2);

        printf("READY=%d  DATA0=%d\n", ready, data0);
    }

    return 0;
}