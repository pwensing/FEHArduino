#include <FEHArduino.h>
#include <FEHSerialIO.h>
#include <FEHTime.h>
extern int main();

int ArduinoMain()
{
    init();
    SerialInitialize(57600);
    main();
    Sleep(1000);
}
