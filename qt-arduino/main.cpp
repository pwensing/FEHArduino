#include <FEHSerialIO.h>
#include <FEHTime.h>
#include <FEHDigitalIO.h>

int ledPin =  13;    // LED connected to digital pin 13
int main()
{
    for(;;) {
        int integer = 5;
        Serialprintf( "I'm a char %c and an int %d\r\n", 'x', integer );
        char buffer[ 19 ] = "so stringies";
        Serialprintf( "A string! %s \r\n", buffer );
        Serialprintf( "flooooooaaaat %.3lf\r\n", (double) 3.14159 );
        Serialprintf( "I point to 5 %p\r\n", &integer );
        Serialprintf( "Stop being negative! %d\r\n", integer * -1 );
        Serialprintf( "pad %1d\r\n", integer );
        Serialprintf( "pad %2d\r\n", integer );
        Serialprintf( "pad %3d\r\n", integer );
        Serialprintf( "pad %4d\r\n", integer );
        Serialprintf( "pad %5d\r\n", integer );
        Serialprintf( "pad %6d\r\n", integer );
        Serialprintf( "We've been doing this for %f seconds\r\n", TimeNow());
        Serialprintf( "And repeat!\r\n" );
        DigitalWrite(ledPin,true);
        Sleep(.5 );
        DigitalWrite(ledPin,false);
        Sleep(.5);
    }


    return 0;
}
