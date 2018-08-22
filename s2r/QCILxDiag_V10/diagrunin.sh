#!/bin/bash
#ONLY 1st line of batch script = Declare the bash this script uses.

DIAG_VER=0.98
BATCH_LOG="Output.log"
MAC_0=`ifconfig |grep eth0|sed 's/^.*HWaddr //'|awk 'BEGIN {FS=":"} {print $1$2$3$4$5$6}'|sed 's/^/MAC_/'`
ret=""
rm $BATCH_LOG -f >> /dev/null
rm Logfile.log -f >>/dev/null

function FT()
{
	echo -e "[-$1- test start...]"|tee -a $BATCH_LOG     		#$1=SHOW_DIAG_TITLE
	retry=0                             #CDROM/USB/COM test 3 times
	if [ "$1" == "CDROMtest" ]; then
		while [ $retry -lt 3 ]
		do
			./$2		
			ret=$?
			if [ "$ret" == "0" ]; then
				retry=100
			else
				retry=`expr $retry + 1`
				umount /mnt/cdrom
  				eject /dev/sr0
				if [ "$rerty" != 3 ]; then
  					echo -e "\e[3${retry}m  Please insert or replace CD. Press any key to continue(Retry=${retry})...\e[0m"
					../tools/anykey
                	echo "Waiting for 20s to mount the CD..."
                	sleep 20 
					mount -o loop /dev/sr0 /mnt/cdrom
					sleep 5
				fi
			fi	
		done
		
	  elif [ "$1" == "USB" ]; then
		while [ $retry -lt 3 ]
		do
			./$2		
			ret=$?
			if [ "$ret" == "0" ]; then
				retry=100
			else
				retry=`expr $retry + 1`
				if [ "$retry" != "3" ]; then
  					echo -e "\e[3${retry}m  Please insert or replace USB drive. Press any key to continue(Retry=${retry})...\e[0m"
					../tools/anykey
                	echo "Waiting for 10s to mount USB drive..."
                	sleep 10 
                fi
			fi	
		done
		
    elif [ "$1" == "COM_PORT" ]; then
		while [ $retry -lt 3 ]
		do
			./$2		
			ret=$?
			if [ "$ret" == "0" ]; then
				retry=100
			else
				retry=`expr $retry + 1`
				if [ "$retry" != "3" ]; then
  					echo -e "\e[3${retry}m  Please insert or replace COM loopback. Press any key to continue(Retry=${retry})...\e[0m"
					../tools/anykey
                	echo "Waiting for 10s to re-test..."
                	sleep 10 
                fi
			fi	
		done
	else
		./$2		
		ret=$?              #$?=return value
	fi
	
	echo |tee -a $BATCH_LOG
		if [ "$ret" == "0" ]; then		     	#judge $?="0" 0=test pass
	        echo -e "\033[1;42m$1 Test PASS!" "(ErrorLevel=$ret)\033[0m"|tee -a $BATCH_LOG
		else
			    echo -e "\033[1;41m$1 Test FAIL. (ErrorLevel = $ret)\033[0m"|tee -a $BATCH_LOG
			 read
       lhand -z $mnt_monitor_path -l -s -L "$1 test fail"          #send fail meg to SFC
       show_exit
		fi
	echo -e "[-$1- test end]\n\n"|tee -a $BATCH_LOG
	sleep 1
}

clear
echo -e "\033[1m[QCILxDiag] Ver$DIAG_VER by Quanta Computer Inc.\033[0m"|tee -a $BATCH.LOG
echo  ""  |tee -a $BATCH.LOG


#CPU(lcpu)
DIAG_NAME=CPUtest
FT "CPU(Cache)" "$DIAG_NAME --c"
FT "CPU(FPU)" "$DIAG_NAME --f"
FT "CPU(MMX)" "$DIAG_NAME --m"
FT "CPU(SSE)" "$DIAG_NAME --s"
FT "CPU(SSE2)" "$DIAG_NAME --e"
FT "CPU(SMP)" "$DIAG_NAME --p"
FT "CPU(SMP Cache)" "$DIAG_NAME --q"    

#SSE4
DIAG_NAME=SSE4test
FT "CPU_SSE4" "$DIAG_NAME -a"      #SSE4test not support SSE4.1 techonology

#Video
DIAG_NAME=lvram
FT "Video(lvram)" "$DIAG_NAME"

DIAG_NAME=lvreg
FT "Video(lvreg)" "$DIAG_NAME"


#PIC
DIAG_NAME=PICtest
FT "PIC" "$DIAG_NAME"

#RTC
DIAG_NAME=RTCtest
FT "RTC" "$DIAG_NAME --a"


#rwDMA
DIAG_NAME=rwDMA
FT "RW_DMA" "$DIAG_NAME"


#Memory
DIAG_NAME=memtest    
  FT "Memory" "$DIAG_NAME --module 32 --size 1024000" 

echo  ""  |tee -a $BATCH.LOG                                                             
echo "End of Ver$DIAG_VER QCILxDiag Tests!!!" echo  ""  |tee -a $BATCH.LOG     
echo  ""  |tee -a $BATCH.LOG     
echo  ""  |tee -a $BATCH.LOG     