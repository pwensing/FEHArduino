ARDUINO_DIR            = %ARDUINO_PATH%
TARGET                 = %ProjectName%

PORT_FINDER 	       = utils/FindSerial/FindSerialDevice.exe
VENDOR_ID 	       = 0403
PRODUCT_ID             = 6001

PUTTY_CONF             = utils/PuttyConf/putty.reg

FEH_CORE_PATH = FEHArduino

ARDUINO_LIBS           =
MCU                    = atmega328p

F_CPU                  = 16000000
BOARD_TAG = nano328


AVR_TOOLS_PATH = $(ARDUINO_DIR)\hardware\tools\avr\bin
ARDUINO_ETC_PATH = $(ARDUINO_DIR)\hardware\tools\avr\etc
HARDWARE_TOOLS_PATH = $(ARDUINO_DIR)\hardware\tools

VARIANT = eightanaloginputs
MCU = atmega328p
AVRDUDE_ARD_PROGRAMMER = arduino
AVRDUDE_ARD_BAUDRATE = 57600
ISP_LOCK_FUSE_PRE  = 0x3F
ISP_LOCK_FUSE_POST  = 0x0F
ISP_HIGH_FUSE = 0xDA
ISP_LOW_FUSE = 0xFF
ISP_EXT_FUSE = 0x05

include FEHArduino.mk
