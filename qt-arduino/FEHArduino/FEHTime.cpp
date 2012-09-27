#include "FEHArduino.h"
#include "FEHTime.h"

void Sleep(float seconds)
{
    delay( (int) (seconds*1000));
}


float TimeNow()
{
    int milliTime = millis();
    return milliTime/1000.;
}
