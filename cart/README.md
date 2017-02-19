# Mapper

* Write to $0000~$3FFF:

| Bit     |   7~6  |  5  |  4  |      3      | 2~0  |
| ------- | ------ | --- | --- | ----------- | ---- |
|         | Unused | DIN | SCK | CHIP SELECT | BANK |

Value at reset: $00

CHIP SELECT: 0=EEPROM 1=ADC

* Read from $A000~$BFFF:
D0 is DOUT from EEPROM or ADC (depends on CHIP SELECT).

# Details

* U1 is a 128*8kb EEPROM
* U2 is the mapper register
* U3 is actually a 25128 128*8kb SPI EEPROM
* U4 is used to lock $0000~$3FFF to bank 0
* U5 is used to invert signals and gate DOUT
* U6:A and U6:C decode writes to $0000~$3FFF
* U6:B decodes reads from $A000~$BFFF
* U7 is an ADC0804 4-channel SPI ADC
