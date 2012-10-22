#include "FEHArduino.h"
#include "FEHSerialIO.h"
#include "FEHDigitalIO.h"

// Set the specified pin as a digital output
// Return value: true = success, false = error occurred
bool SetDigitalOutput( unsigned int pinnumber )
{
    SetDigitalMode(pinnumber,DIGITAL_OUTPUT);
}

// Set the specified pin as a digital input
bool SetDigitalInput( unsigned int pinnumber )
{
    SetDigitalMode(pinnumber,DIGITAL_INPUT);
}

// Set the digital input/output mode for the pin
bool SetDigitalMode( unsigned int pinnumber, DigitalMode mode )
{
    if( mode == DIGITAL_INPUT)
    {
        pinMode(pinnumber, INPUT);
        digitalWrite(pinnumber,HIGH);
    }
    else
    {
        pinMode(pinnumber,OUTPUT);
    }
}

// Get the digital pin mode for the specified pin
DigitalMode GetDigitalMode( unsigned int pinnumber )
{
    return DIGITAL_INPUT;
}

// Read the status of the specified digital input
bool DigitalRead( unsigned int pinnumber )
{
    return digitalRead(pinnumber);
}

// Sets the state of the digital output pin
// Return value: true = status successfully set, false = error
bool DigitalWrite( unsigned int pinnumber, bool value )
{
    if (value)
    {
        digitalWrite(pinnumber,HIGH);
    }
    else
    {
        digitalWrite(pinnumber,LOW);
    }
}

// Get the state of the digital output pin
bool DigitalStatus( unsigned int portnumber )
{
    return true;
}
