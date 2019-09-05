#include <stdio.h>
#include <stdlib.h>
#include "io.h"
#include "altera_up_avalon_video_character_buffer_with_dma.h"


int main (void)
{
	alt_up_char_buffer_dev *dev1;
	alt_up_char_buffer_init(dev1);
	dev1 = alt_up_char_buffer_open_dev("/dev/video_character_buffer_with_dma_0");
	alt_up_char_buffer_clear(dev1);

	volatile int * SW_switch_ptr = (int *) 0x00004000;
	volatile int * contador = (int *) 0x00001010; // contador
	int * memoria = (int *) 0x00080000; //memoria
	int SW_value;
	char read[50];
	char input[100];
	char time[100];
	int prueba;
	int consulta_val;
	int _consulta = 25;
	IOWR(memoria,0x000a0000,_consulta);

	while (1){
		//printf("El resultado es: %d\n",*(contador+2));

		SW_value = *(SW_switch_ptr);
		int band = 0;
		*(contador+1)=0;
		*(contador)=4;
		*(contador)=2;
		alt_up_char_buffer_string(dev1, "Utilice una combinación de switch (SW0,SW1,SW2) para realizar consulta. ", 0,5);
		alt_up_char_buffer_string(dev1, "Utilice SW9 para mostrar la consulta realizada. ", 0,6);
		if(SW_value&512){
			alt_up_char_buffer_clear(dev1);
			consulta_val = IORD(memoria,0x000a0000);
			prueba = IORD(memoria,0x00090000);//consultamos el numero de consulta;
			printf("%d\n",prueba);
			sprintf(read, "%d", consulta_val);
			alt_up_char_buffer_string(dev1, "Mostrando consulta:", 0,1);
			alt_up_char_buffer_string(dev1, "TABLA: sensor_temp:", 0,3);
			alt_up_char_buffer_string(dev1, "Temperatura (ultimo registro):", 0,4);
			alt_up_char_buffer_string(dev1, read, 50,4);
			alt_up_char_buffer_string(dev1, "En el segundo: ", 0,47);
			sprintf(time, "%d", *(contador+2));
			alt_up_char_buffer_string(dev1, time, 17,47);
			band = 1;

			/*
			char * read = IORD(memoria,0x00080000);//a
			alt_up_char_buffer_clear(dev1);
			sprintf(time, "%d", *(contador+2));
			alt_up_char_buffer_string(dev1, "Mostrando consulta:", 0,1);
			alt_up_char_buffer_string(dev1, read, 0,2);
			alt_up_char_buffer_string(dev1, "En el segundo: ", 0,4);
			alt_up_char_buffer_string(dev1, time, 17,4);
			band = 1;*/
		}
		if(band==1)
		{	usleep(4000000);
			SW_value = *(SW_switch_ptr);
			while(SW_value&512){
				alt_up_char_buffer_string(dev1, "****************************************************************", 0,49);
				alt_up_char_buffer_string(dev1, "Regrese el switch a la posicion original para seguir consultado. ", 0,50);
				SW_value = *(SW_switch_ptr);
				printf("%d\n",SW_value);
				usleep(90000);
			}
			alt_up_char_buffer_clear(dev1);
			band =0;
		}

	}
}


