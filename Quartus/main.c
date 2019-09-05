#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
#define ON_CHIP_WR ( 0x00090000 )
int leerConsulta(int numero);

void* virtual_base;
void* sw_addr;
void* on_chip;
void* prueba;
int fd;
int sw_value;
char * onchip_value;
char * texto ;
int consulta;
int valor;



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
prueba=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + ON_CHIP_WR) & ( unsigned long)( HW_REGS_MASK ) ); 
//* on_chip = 0;
//printf("%p\n",&on_chip);

while(1){
sw_value=*(uint32_t *)sw_addr;
usleep(1000000);
printf("%u\n",sw_value);

if(sw_value==1){
	consulta = 1;
	system("./mostrar.sh");		
	valor = leerConsulta(consulta);
	//printf("%p\n",&on_chip);
	printf("%d\n",valor);
	if (valor == -1){
		valor = 0; //Valido error de archivo		
	}
	*(uint32_t *)on_chip=valor;
	*(uint32_t *)prueba=12;
	
	printf("Entro en el SW 1\n");
}
if(sw_value==2){
	consulta = 2;
	system("./mostrar.sh");		
	valor = leerConsulta(consulta);
	//printf("%p\n",&on_chip);
	printf("%d\n",valor);
	if (valor == -1){
		valor = 0; //Valido error de archivo		
	}
	
	*(uint32_t *)on_chip=valor;
	printf("Entro en el SW 2\n");
}
if(sw_value==4){
	consulta = 3;
	system("./mostrar.sh");		
	valor = leerConsulta(consulta);
	//printf("%p\n",&on_chip);
	printf("%d\n",valor);
	if (valor == -1){
		valor = 0; //Valido error de archivo		
	}
	*(uint32_t *)on_chip=valor;
	printf("Entro en el SW 3\n");
}
/*
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

int leerConsulta(int numero){
	FILE *file; //puntero del archivo
	int value=-1;
	char cadena [100];
	char texto [20];
	int contador = 0;
	file = fopen ("consulta.txt","r"); //nombre del archivo a leer
	if (file==NULL){
		printf("\nError de apertura del archivo.");
	}
	else{

		while(feof(file)==0) //revisa lineas de archivo
		{	
			fgets(cadena,100,file);	//extrae la cadena
			//lee lineas de archivo hasta donde haya salto de linea		
			if(contador + 1 == numero){
				strcpy(texto, cadena);
				value=atoi(cadena);
				break;
			}
			contador = contador + 1;
			
		}
		if(value == -1){ //validacion si no se inicializa
			strcpy(texto, "404 Not Found");
			value = 0;		
		}	

		/*
		printf("Caracter: %s\n", texto);
		printf("Numero: %d\n", value);*/
	}
	

	fclose(file);//cerrar el archivo y retornar valor
	return value;
	
}