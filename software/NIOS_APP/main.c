
#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

#define FRAME_WIDTH			1024
#define FRAME_HEIGHT		768
#define FRAME_BACKGROUN_R		0
#define FRAME_BACKGROUN_G		0
#define FRAME_BACKGROUN_B		255

#define  VIDEO_IN_WIDTH			270
#define  VIDEO_IN_HEIGHT		200

void MIX_Reset(int bGo){
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0, 0x00); // stop

	IOWR(ALT_VIP_CL_MIXER_0_BASE, 3, FRAME_WIDTH); // frame width
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 4, FRAME_HEIGHT); // frame height
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 5, FRAME_BACKGROUN_R);
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 6, FRAME_BACKGROUN_G);
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 7, FRAME_BACKGROUN_B);

	// layer 0
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+0, 0x00); // x offset
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+1, 0x00); // y offset
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+2, 0x00); // disable

	// layer 1
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 13+0, 0x00); // x offset
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 13+1, 0x00); // y offset
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 13+2, 0x00); // disable

	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0x00, bGo?0x01:0x00); // go
}

// layer: background layer, layer0, layer1

// nLayer = 0: means layer 0
// nLayer = 1: means layer 1


void MIX_EnableLayer(int nLayer, int bEnable, int x, int y){
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0x00, 0x00); // stop
	usleep(200*1000);
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+nLayer*5+ 2, bEnable?0x01:0x00); // layer disable
	if (bEnable){
		IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+nLayer*5+ 0, x);
		IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+nLayer*5+ 1, y);
	}
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0x00, 0x01); // go
}

void MIX_MoveLayer(int nLayer, int bEnable, int x, int y){
//	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0x00, 0x00); // stop
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+nLayer*5+ 0, x);
	IOWR(ALT_VIP_CL_MIXER_0_BASE, 8+nLayer*5+ 1, y);
//	IOWR(ALT_VIP_CL_MIXER_0_BASE, 0x00, 0x01); // go
}


#define LAYER_ENABLE 	0x01
#define LAYER_DISABLE 	0x00



int config_for_linux(){
	// config mixer
	const int bGo = 1; //1:go, 0:no-go
	const int nLayer1 = 0;
	const int nLayer2 = 1;

	printf("Init VIP\n");
	MIX_Reset(bGo);

	printf("show background\r\n");
	usleep(3000*1000); // show color bar

	printf("enable layer 1(linux frame buffer)\r\n");
	MIX_EnableLayer(nLayer1, LAYER_ENABLE, 0, 0);

	////////////////////////////////
	// config for composite video-in

	// disable decoder (layer 2)
	MIX_EnableLayer(nLayer2, LAYER_DISABLE, 0, 0);

	// config scaler. scale to (VIDEO_IN_WIDTH, VIDEO_IN_HEIGHT) and enable it
#if TV_DECODER_ALT_VIP_CL_SCL_0_BASE
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x03, VIDEO_IN_WIDTH); // output width
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x04, VIDEO_IN_HEIGHT); // output height
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x00, 0x01); // go
#endif

	return 0;

}


int test()
{
	int led_mask, i;
	const int bGo = 1; //1:go, 0:no-go
	const int nLayer1 = 0;
	const int nLayer2 = 1;
	const int nLayer3 = 2;

	printf("Init VIP\n");

#if TV_DECODER_ALT_VIP_CL_CVI_0_BASE
	IOWR(TV_DECODER_ALT_VIP_CL_CVI_0_BASE, 0x00, 0x01); // go
#endif

#if TV_DECODER_ALT_VIP_CL_SCL_0_BASE
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x03, 270+200); // output width
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x04, 200+200); // output height
	IOWR(TV_DECODER_ALT_VIP_CL_SCL_0_BASE, 0x00, 0x01); // go
#endif

	MIX_Reset(bGo);


	// led blink
	led_mask = 0x01;
	for(i=0;i<10;i++){
		IOWR(LEDR_BASE, 0x00, led_mask);
		led_mask <<= 1;
		usleep(20*1000);
	}

	led_mask = 0x01 << 9;
	for(i=0;i<10;i++){
		IOWR(LEDR_BASE, 0x00, led_mask);
		led_mask >>= 1;
		usleep(20*1000);
	}
	IOWR(LEDR_BASE, 0x00, 0x00);


  // init VIP mixer II

	printf("show background\r\n");
	usleep(3000*1000); // show color bar

	//MIX_EnableLayer(nLayer1, LAYER_ENABLE, 0, 0);

	printf("show layer 1\r\n");
	MIX_EnableLayer(nLayer1, LAYER_ENABLE, 0, 0);
	usleep(5000*1000);

	printf("show layer 2\r\n");
	MIX_EnableLayer(nLayer2, LAYER_ENABLE, 10, 10); // cannot be (0,0)

	usleep(5000*1000);

	printf("show layer 3\r\n");
	MIX_EnableLayer(nLayer3, LAYER_ENABLE, 300, 300); // cannot be (0,0)


	int x=1, y=1;
	while(1){
		MIX_MoveLayer(nLayer2, LAYER_ENABLE, x, y); // cannot be (0,0)
		usleep(2000);
		x++;
		if (x > 400)
			x = 1;
	}



}


int main(){
	int result;

	result = config_for_linux();
	return result;
}
