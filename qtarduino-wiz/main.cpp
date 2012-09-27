#include "FEHArduino.h"
#include "FEHSerialIO.h"
#include "FEHTime.h"

int main()
{
    SerialInitialize( 9600 );
    while (1==1) {
        Serialprintf( "Hello World!\r\n");
        Sleep(.5);
    }
    return 0;
}
