// FEHDigitalIO.h

#ifndef _FEH_DIGITAL_IO_
#define _FEH_DIGITAL_IO_

// Set the specified pin as a digital output
// Return value: true = success, false = error occurred
bool SetDigitalOutput( unsigned int pinnumber );

// Set the specified pin as a digital input
bool SetDigitalInput( unsigned int pinnumber );

// enumeration for the modes of a digital pin
enum DigitalMode
{
	DIGITAL_INPUT = 0,
	DIGITAL_OUTPUT
};

// Set the digital input/output mode for the pin
bool SetDigitalMode( unsigned int pinnumber, DigitalMode mode );

// Get the digital pin mode for the specified pin
DigitalMode GetDigitalMode( unsigned int pinnumber );

// Read the status of the specified digital input
bool DigitalRead( unsigned int pinnumber );

// Sets the state of the digital output pin
// Return value: true = status successfully set, false = error
bool DigitalWrite( unsigned int pinnumber, bool value );

// Get the state of the digital output pin
bool DigitalStatus( unsigned int portnumber );

#endif
