#ifndef soc_cv_av 
#define soc_cv_av
#endif

#include <string.h>
#include <stdlib.h>
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

#define DATA_LENGTH 1024

int main() {

	void *virtual_base;
	int fd;
	int loop_count;
	char  pipe_in_string[64];

	void *h2p_lw_rddat_vaddr;
	void *h2p_lw_rdadd_vaddr;
	
	void *h2p_lw_rdflg_vaddr;
	void *h2p_lw_analog_v_ctrl_vaddr; // {o_ACDC_CTRL, o_RELY_GAIN, gain_pwm_set[7:0], 6'bz}

	int set_acdc_ctrl = 0;
	int set_relay_gain = 0;
	int set_gain_pwm_set = 0;
	
	char * p_string;
	
	int A_Data_Array[DATA_LENGTH];
	int B_Data_Array[DATA_LENGTH];


	// map the address space
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		return( 1 );//Err
	}
	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );
	if( virtual_base == MAP_FAILED ) {
		close( fd );
		return( 1 );//Err mmap() failed
	}
	h2p_lw_rdadd_vaddr = virtual_base + ( ( unsigned long )( ALT_LWFPGASLVS_OFST + PIO_RDADD_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	h2p_lw_rddat_vaddr = virtual_base + ( ( unsigned long )( ALT_LWFPGASLVS_OFST + PIO_RDDAT_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	h2p_lw_rdflg_vaddr = virtual_base + ( ( unsigned long )( ALT_LWFPGASLVS_OFST + PIO_RDFLG_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
    h2p_lw_analog_v_ctrl_vaddr = virtual_base + ( ( unsigned long )( ALT_LWFPGASLVS_OFST + PIO_ANALOG_V_CTRL_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	
	loop_count = 0;
	
	// Save data to the array
	while(1){
		
		 // Receive Command String. 
		 //The string sent by sender should include '\n', then sender should flush stdin.
		 //but the '\n' will not be read by 'gets'.
		gets(pipe_in_string);
		p_string = (char *)pipe_in_string;
		set_acdc_ctrl = atoi(p_string+2)<<15;
		set_relay_gain = atoi(p_string+2+2)<<14;
		set_gain_pwm_set = atoi(p_string+2+2+2)<<6;
		
		
		
		*(uint32_t *)h2p_lw_rdflg_vaddr  = 1;
		*(uint32_t *)h2p_lw_analog_v_ctrl_vaddr = set_acdc_ctrl + set_relay_gain + set_gain_pwm_set;
		
		//*(uint32_t *)h2p_lw_analog_v_ctrl_vaddr = 0x4000; // 0|100 0000 0|000 0000
		//*(uint32_t *)h2p_lw_analog_v_ctrl_vaddr = 0xC000; // 1|100 0000 0|000 0000
		for (loop_count = 0; loop_count < DATA_LENGTH; loop_count++){
			
			*(uint32_t *)h2p_lw_rdadd_vaddr  =   loop_count;
			//A_Data_Array[loop_count] = ((int)*(uint32_t *)h2p_lw_rddat_vaddr)>>8;
			B_Data_Array[loop_count] = ((int)*(uint32_t *)h2p_lw_rddat_vaddr)&(0xff);
			
		} 
		*(uint32_t *)h2p_lw_rdflg_vaddr  = 0;
		// Print out the array
		for (loop_count = 0; loop_count < DATA_LENGTH; loop_count++){
			
			printf("%5d\n",B_Data_Array[loop_count]);
			
			//printf("%5d\n",A_Data_Array[loop_count]);
		}
		fflush(stdout);
	}

	// Clean up memory mapping and exit
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		close( fd );
		return( 1 );//Err
	}

	close( fd );
	return( 0 );
}
