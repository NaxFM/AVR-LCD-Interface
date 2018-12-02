;
; 8BitLCDInterface.asm
;
; Created: 02/12/2018 18:31:03
; Author : mistr
;


; Replace with your application code
//Define pin to use for LCD Data transfer
//Must define only one, comment the other
#define LCD_DATA_PORT_B  
//#define LCD_DATA_PORT_D

//Define pin to use for LCD register select pin
//Must define only one, comment the others
//Must not be the same set of pins as LCD_DATA_PORT_X 
//#define LCD_RS_PORT_B
#define LCD_RS_PORT_C
//#define LCD_RS_PORT_D


//define port to use for LCD read/write pin
//Must define only one, comment the others
//Must not be the same set of pins as LCD_DATA_PORT_X
//Can be same set of LCD_RS_PIN_C but if so LCD_RS_PIN must be different from LCD_RW_PIN
//#define LCD_RW_PORT_B
#define LCD_RW_PORT_C
//#define LCD_RW_PORT_D


//Define the number of the RS pin
//Must be 0 to 7
#define RS_PIN 0

//Define the number of RW pin
//If using same port for LCD_RW_PORT and LCD_RS_PORT, then this pin must be different from LCD_RS_PIN_X
#define RW_PIN 1

//Define register to be used for temporary data 
//Must be between r16 and r31
#define TEMP_REG R16

//define number of lcd lines
//Select number of lines according to your lcd, comment the other option 
//#define NUMBER_OF_LINES_1
#define NUMBER_OF_LINES_2 


//End user define

//Definition of commands
#define ClearDisplay 0x01
#define ReturnHome 0x02
#


//end definition of commands
#define BUSY_FLAG 7

//ifdef for RW pin

#ifdef LCD_RW_PORT_B
#define RW_DDR DDRB
#define RW_PORT PORTB
#endif

#ifdef LCD_RW_PORT_C
#define RW_DDR DDRC
#define RW_PORT PORTC
#endif

#ifdef LCD_RW_PORT_D
#define RW_DDR DDRD
#define RW_PORT PORTD
#endif

//ifdef for RS pin
#ifdef LCD_RS_PORT_B
#define RS_DDR DDRB
#define RS_PORT PORTB
#endif 

#ifdef LCD_RS_PORT_C
#define RS_DDR DDRC
#define RS_PORT PORTC
#endif 

#ifdef LCD_RS_PORT_D
#define RS_DDR DDRD
#define RS_PORT PORTD
#endif 

//ifdef data port
#ifdef LCD_DATA_PORT_B
#define DATA_DDR DDRB
#define DATA_PORT PORTB
#define DATA_PIN PINB
#endif

#ifdef LCD_DATA_PORT_D
#define DATA_DDR DDRD
#define DATA_PORT PORTD
#define DATA_PIN PIND
#endif


LCDInit:
	sbi RS_DDR, RS_PIN //sets LCD_RS_PIN as output
	sbi RW_DDR, RW_PIN //sets LCD_RW_PIN as output
	ldi TEMP_REG , 0x7F
	out DATA_DDR, TEMP_REG	;Setting Data Pins 6 to 0 as outputs
	cbi RS_PORT, RS_PIN  //Clears RS_PIN 
	sbi RW_PORT, RW_PIN //set RW_PIN to read busy flag 
    rcall WaitForBusyFlag// wait until not busy	
  
SendInitiCommand:
	ldi TEMP_REG, 0x30 //sets font and data lenght to 8bit 

//Setting pin for number of lines
#ifdef NUMBER_OF_LINES_1
	cbr TEMP_REG, 0x08 //clears line bit to select 1 line 
#endif

#ifdef NUMBER_OF_LINES_2
	sbr TEMP_REG, 0x08 //set line bit to select 2 lines
#endif
//end setting of pin for number of lines 
	sbi DATA_DDR, BUSY_FLAG // Set data pin 7 as output 
	out DATA_PORT, TEMP_REG //output data 
	cbi RW_PORT, RW_PIN //clears RW_PIN to start writing
	rcall WaitForBusyFlag	//wait until not busy
		
	ret //return
//initialization finished 


.MACRO SendCommand
	cbi RS_PORT, RS_PIN  //Clears RS_PIN 
	sbi RW_PORT, RW_PIN //Set RW_PIN to read busy flag 
	rcall WaitForBusyFlag //waits for busy flag
	ldi TEMP_REG, @0
	out DATA_PORT, TEMP_REG // send command
	cbi RW_PORT, RW_PIN //clears RW_PIN
	rcall WaitForBusyFlag // waits for busy flag
	ret
.ENDMACRO


WaitForBusyFlag: //wait for busy flag, this function sets busy flag pin as input
	cbi DATA_DDR, BUSY_FLAG //set data pin 7 as input to read busy flag 
	sbic DATA_PIN, BUSY_FLAG //skip next instruction if not busy
	rjmp WaitForBusyFlag
	ret //return

Start: 
	inc r16
	rjmp start 