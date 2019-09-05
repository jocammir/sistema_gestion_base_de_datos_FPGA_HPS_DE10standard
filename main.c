#include <stdio.h>
#include <unistd.h>
#include <fcntl.h> 
#include <sys/mman.h> 
#include "hwlib.h" 
#include "socal/socal.h"
#include "socal/hps.h" 
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )
//#define ON_CHIP_WR 0x000a0000
void* virtual_base;
void* sw_addr;
void* on_chip;
int fd;
int sw_value;
char * onchip_value;
char * texto ;



int main (){
fd=open("/dev/mem",(O_RDWR|O_SYNC));
virtual_base=mmap(NULL,HW_REGS_SPAN,(PROT_READ|PROT_WRITE),MAP_SHARED,fd,HW_REGS_BASE);
if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( 1 );
	}
sw_addr=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + SW_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
on_chip=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + ONCHIP_MEMORY2_BASE ) & ( unsigned long)( HW_REGS_MASK ) );

 //* on_chip = 0;

while(1){
sw_value=*(uint32_t *)sw_addr;
usleep(1000000);
printf("%u\n",sw_value);
if(sw_value==1){
	onchip_value =*(char *) on_chip; 
	printf("%s\n",onchip_value);
	printf("Entro en el SW 1\n");
}/*
if(sw_value==2){
	*(char *) on_chip = (char)"Hola Mundox";
	onchip_value=*(char *)on_chip;
	printf("%s\n",onchip_value);
	printf("Entro en el SW 2\n");
}
*/
}
return 0;
}