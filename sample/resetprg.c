/***********************************************************************/
/*                                                                     */
/*  FILE        :resetprg.c                                            */
/*  DATE        :Sat, Mar 06, 2021                                     */
/*  DESCRIPTION :Reset Program                                         */
/*  CPU TYPE    :SH7763                                                */
/*                                                                     */
/*  This file is generated by Renesas Project Generator (Ver.4.19).    */
/*  NOTE:THIS IS A TYPICAL EXAMPLE.                                    */
/***********************************************************************/
/*********************************************************************
*
* Device     : SH-4A
*
* File Name  : resetprg.c
*
* Abstract   : Initialize for C/C++ language.
*
* History    : 1.00  (2008-01-24)
*              1.10  (2010-06-22)
*
* NOTE       : THIS IS A TYPICAL EXAMPLE.
*
* Copyright (C) 2008 (2010) Renesas Electronics Corporation and
* Renesas Solutions Corp. All rights reserved.
*
*********************************************************************/

#include	<machine.h>
#include	<_h_c_lib.h>
//#include	<stddef.h>					// Remove the comment when you use errno
//#include 	<stdlib.h>					// Remove the comment when you use rand()
#include	"typedefine.h"
#include	"stacksct.h"

#define SR_Init    0x000000F0
#ifdef _FPD	// when -fpu=double is specified
#define FPSCR_Init 0x000C0001
#else
#define FPSCR_Init 0x00040001
#endif
#ifdef _RON	// when -round=nearest is specified
#define FPSCR_RM 0xfffffffc
#else
#define FPSCR_RM 0xfffffffd
#endif
#ifdef _DON	// when -denormalize=on is specified
#define FPSCR_DN 0xfffbffff
#else
#define FPSCR_DN 0xffffffff
#endif
#define INT_OFFSET 0x100UL

#define RAMCR_ADDRESS       0xff000074
#define RAMCR_INIT_VALUE    0x00000200

#ifdef __cplusplus
extern "C" {
#endif
extern void INTHandlerPRG(void);
void PowerON_Reset(void);
void Manual_Reset(void);
void main(void);
#ifdef __cplusplus
}
#endif

//#ifdef __cplusplus				// Enable I/O in the application(both SIM I/O and hardware I/O)
//extern "C" {
//#endif
//extern void _INIT_IOLIB(void);
//extern void _CLOSEALL(void);
//#ifdef __cplusplus
//}
//#endif

//extern void srand(_UINT);		// Remove the comment when you use rand()
//extern _SBYTE *_s1ptr;				// Remove the comment when you use strtok()
		
//#ifdef __cplusplus				// Use Hardware Setup
//extern "C" {
//#endif
//extern void HardwareSetup(void);
//#ifdef __cplusplus
//}
//#endif
	
//#ifdef __cplusplus			// Remove the comment when you use global class object
//extern "C" {					// Sections C$INIT and C$END will be generated
//#endif
//extern void _CALL_INIT(void);
//extern void _CALL_END(void);
//#ifdef __cplusplus
//}
//#endif

#pragma section ResetPRG

#pragma entry PowerON_Reset

void PowerON_Reset(void)
{
    volatile _UDWORD* ramcr_address;

	set_vbr((void *)((_UINT)INTHandlerPRG - INT_OFFSET));

	set_fpscr(FPSCR_Init & FPSCR_RM & FPSCR_DN);

//	HardwareSetup();				// Use Hardware Setup

	_INITSCT();

//	_CALL_INIT();					// Remove the comment when you use global class object

//	_INIT_IOLIB();					// Enable I/O in the application(both SIM I/O and hardware I/O)

//	errno=0;						// Remove the comment when you use errno
//	srand((_UINT)1);					// Remove the comment when you use rand()
//	_s1ptr=NULL;					// Remove the comment when you use strtok()

    ramcr_address = (_UDWORD*)RAMCR_ADDRESS;
    *ramcr_address = RAMCR_INIT_VALUE;
	set_cr(SR_Init);

	main();

//	_CLOSEALL();					// Close I/O in the application(both SIM I/O and hardware I/O)

//	_CALL_END();					// Remove the comment when you use global class object

	while(1);
}

void Manual_Reset(void)	
{
} 
