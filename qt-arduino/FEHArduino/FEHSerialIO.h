// FEHSerialIO.h

#ifndef _FEH_SERIAL_IO_
#define _FEH_SERIAL_IO_

#include <inttypes.h> 
#include <avr/io.h>
#include <stdio.h>
#include <stdbool.h>

// Initialize serial communication at specified baud rate
bool SerialInitialize( unsigned int baudrate );

// printf function for output to a serial terminal
void Serialprintf( const char* string, ... );

// scanf function for input from a serial terminal
int  Serialscanf( const char* format, ... );

#endif