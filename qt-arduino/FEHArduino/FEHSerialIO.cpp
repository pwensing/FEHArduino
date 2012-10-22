// FEHSerialIO.c

//#include <Serial.h>
#include <Arduino.h>
#include <stdarg.h>
#include "FEHSerialIO.h"


// Initialize serial communication at specified baud rate
bool SerialInitialize( unsigned int baudrate )
{
	Serial.begin( baudrate );
}

void Serialprintf( const char* string, ... )
{
        char tmp[ 512 ]; // resulting string limited to 128 chars
        va_list args;
        va_start( args, string );
        vsnprintf( tmp, 512, string, args );
        va_end( args );
        Serial.print( tmp );
}


//// comments from UARTprintf
////*****************************************************************************
////
////! A simple UART based printf function supporting \%c, \%d, \%p, \%s, \%u,
////! \%x, and \%X.
////!
////! \param pcString is the format string.
////! \param ... are the optional arguments, which depend on the contents of the
////! format string.
////!
////! This function is very similar to the C library <tt>fprintf()</tt> function.
////! All of its output will be sent to the UART.  Only the following formatting
////! characters are supported:
////!
////! - \%c to print a character
////! - \%d to print a decimal value
////! - \%s to print a string
////! - \%u to print an unsigned decimal value
////! - \%x to print a hexadecimal value using lower case letters
////! - \%X to print a hexadecimal value using lower case letters (not upper case
////! letters as would typically be used)
////! - \%p to print a pointer as a hexadecimal value
////! - \%\% to print out a \% character
////!
////! For \%s, \%d, \%u, \%p, \%x, and \%X, an optional number may reside
////! between the \% and the format character, which specifies the minimum number
////! of characters to use for that value; if preceded by a 0 then the extra
////! characters will be filled with zeros instead of spaces.  For example,
////! ``\%8d'' will use eight characters to print the decimal value with spaces
////! added to reach eight; ``\%08d'' will use eight characters as well but will
////! add zeroes instead of spaces.
////!
////! The type of the arguments after \e pcString must match the requirements of
////! the format string.  For example, if an integer was passed where a string
////! was expected, an error of some kind will most likely occur.
////!
////! \return None.
////
////*****************************************************************************
//
// 
//
//// printf function for output to a serial terminal
//void Serialprintf( const char* string, ... )
//{
//	unsigned long value;
//	char buffer[ 10 ];
//	unsigned int bufferpos = 0;
//	bool negative = false;
//	unsigned int base = 10;
//	bool convert = false; // flag to say that a number needs converted to string
//
//	// Check arguments
//	//ASSERT( string != 0 );
//
//	// start processing varargs
//	va_list args;
//	va_start( args, string );
//
//	// position in string
//	int index = 0;
//
//	// loop while the string has characters
//	while( string[ index ] != 0 )
//	{
//		// print characters until '%' or end of string is reached
//		while( string[ index ] != '%' && string[ index ] != '\0' )
//		{
//			Serial.print( string[ index ] );
//			index++;
//		}
//
//		if( string[ index ] == '%' )
//		{
//			index++;
//
//			// set the digit count to zero and the fill character to space
//			int digitcount = 0;
//			char fill = ' ';
//			
//			while( isdigit( string[ index ] ) )
//			{
//				if( string[ index ] == 0 && digitcount == 0 )
//				{
//					fill = '0';
//				}
//				
//				digitcount *= 10;
//				digitcount += string[ index ] - '0';
//
//				index++;
//			}
//
//			// reset the convert flag
//			convert = false;
//
//			// process the format character
//			switch( string[ index ] )
//			{
//				case 'c':
//				{
//					Serial.print( (char)( va_arg( args, unsigned long ) ) );
//
//					break;
//				}
//				case 'd':
//				{
//					value = va_arg( args, unsigned long );
//
//					bufferpos = 0;
//
//					// if negative, make it positive
//					if( (long)value < 0 )
//					{
//						negative = true;
//						value = -(long)value;
//					}
//					else
//					{
//						negative = false;
//					}
//
//					base = 10;
//
//					// need to convert a value
//					convert = true;
//					break;
//				}
//				case 's':
//				{
//					char* str = va_arg( args, char* );
//					Serial.print( str );
//					unsigned int len = 0;
//					while( str[ len ] != '\0' )
//					{
//						Serial.print( str[ len ] );
//						len++;
//					}
//
//					// add padding
//					if( digitcount > len )
//					{
//						digitcount -= len;
//						while( digitcount > 0 )
//						{
//							Serial.print( ' ' );
//							digitcount--;
//						}
//					}
//
//					break;
//				}
//				case 'u':
//				{
//					value = va_arg( args, unsigned long );
//
//					bufferpos = 0;
//					base = 10;
//					negative = false;
//					convert = true;
//
//					break;
//				}
//				case 'x':
//				case 'X':
//				case 'p':
//				{
//					value = va_arg( args, unsigned long );
//					bufferpos = 0;
//					base = 16;
//					negative = false;
//
//					convert = true;
//
//					break;
//				}
//				case 'f':
//				{
//					// very basic implementation supported
//					double fvalue = va_arg( args, double );
//					Serial.print( fvalue );
//					break;
//				}
//				case '%':
//				{
//					Serial.print( '%' );
//					break;
//				}
//                default:
//                {
//                    // Indicate an error.
//                    Serial.print( "ERROR" );
//                    break;
//                }
//            }
//
//			// convert number to string
//			if( convert )
//			{
//				// get number of digits in the string to figure out amount of padding
//				index = 1;
//				while( ( index * base ) < value && ( ( index * base ) / base ) == index )
//				{
//					index *= base;
//					digitcount--;
//				}
//
//				// if negative, reduce the amount of padding
//				if( negative )
//				{
//					digitcount--;
//				}
//
//				// if using zeros to pad, put negative sign first
//				if( negative && fill == '0' )
//				{
//					Serial.print( '-' );
//					// turn off negative flag since we've already placed the sign
//					negative = false;
//				}
//
//				// add padding
//				while( digitcount > 1 )
//				{
//					Serial.print( fill );
//					digitcount--;
//				}
//
//				// add negative sign
//				if( negative )
//				{
//					Serial.print( '-' );
//				}
//
//				// convert value to string
//				if( base == 10 )
//				{
//					Serial.print( value );
//				}
//				else if( base == 16 )
//				{
//					Serial.print( value, HEX );
//				}
//			}
//		}
//	}
//
//	// end argument processing
//	va_end( args );
//}
//
//
