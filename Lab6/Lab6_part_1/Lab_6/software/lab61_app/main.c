// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

#include "system.h"

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)LED_BASE; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x60; //defined in system.h
	volatile unsigned int *KEY_PIO_0 = (unsigned int*)0x70; //reset
	volatile unsigned int *KEY_PIO_1 = (unsigned int*)0x80; //accumulation

	int sum = 0;
	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
		if(*KEY_PIO_0==0){ //the key is active low
			sum = 0;
			*LED_PIO = 0;
		}

		else if (*KEY_PIO_1==0){
			while(*KEY_PIO_1==0){//check if the user is keep pressing

			}
			sum = *SW_PIO + sum;
			*LED_PIO = sum;
		}



//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO |= 0x1; //set LSB
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO &= ~0x1; //clear LSB
	}
	return 1; //never gets here
}
