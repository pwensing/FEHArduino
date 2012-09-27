#include "FEHArduino.h"
#include "FEHSerialIO.h"
#include "FEHTime.h"
int ledPin =  13;    // LED connected to digital pin 13

/*void setup() {
    Serial.begin(9600);
    pinMode(ledPin, OUTPUT);
}

void loop() {
    digitalWrite(ledPin, HIGH);   // set the LED on
    delay(500);                   // wait for half a second
    digitalWrite(ledPin, LOW);    // set the LED off
    delay(500);                   // wait for half a second
    Serial.println("Hey!");

}*/



int main()
{
    SerialInitialize( 9600 );
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
        Serialprintf( "And repeat!\r\n" );
        delay( 1000 );
    }


    return 0;
}
