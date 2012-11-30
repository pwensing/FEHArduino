#include <FEHSerialIO.h>
#include <FEHDigitalIO.h>

int main() {

    //Configure Necessary Pins
    SetDigitalOutput(2);
    SetDigitalInput(4);

    // Output +5V on pin 2, read pin 4
    DigitalWrite(2,true);
    Serialprintf( "Output = 1, Input = %d.\r\n", DigitalRead(4) );

    // Output 0V on pin 2, read pin 4
    DigitalWrite(2,false);
    Serialprintf( "Output = 0, Input = %d.\r\n", DigitalRead(4) );
}
