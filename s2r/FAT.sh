#!/bin/bash
ipmitool sel clear
sleep 2

# [ 1 ]==============      FRU write/read check      ===========================
cd /test/s2r/fru
if ! source ./fru.sh ; then
 itemfail "Load fru.sh FAIL !!!"
 show_exit
fi
# [ 2 ]====================    front board Part number check    ================
if ! source ./fp_fru_chk.sh ; then
  itemfail "Load fp_fru_chk.sh FAIL !!!"
  show_exit
fi

# [ 3 ]====================    front board identify check   ====================
cd /test/s2r/bmc
if ! source ./identify_chk.sh ; then
  itemfail "Load identify_chk.sh FAIL !!!"
  show_exit
fi

# [ 4 ]=====================    cpu info check      ============================
cd /test/s2r/cpu
if ! source ./cputest.sh ; then
  itemfail "load cputest.sh Check FAIL !!!"
  show_exit
fi

# [ 5 ]=====================    dimm info check      ===========================
cd /test/s2r/mem
if ! source ./dimm_chk.sh ; then
  itemfail "load dimm_chk.sh Check FAIL !!!"
  show_exit
fi

# [ 6 ]====================    BMC Version check       =========================
cd /test/s2r/bmc
if ! source ./bmc_ver_chk.sh ; then 
 itemfail "Load bmc_ver_chk.sh FAIL !!!"
 show_exit
fi

# [ 7 ]=====================    BIOS Version check      ========================

cd /test/s2r/bios
if ! source ./bios_ver_chk.sh ; then
 itemfail "BIOS Version Check FAIL !!!"
 show_exit
fi
# [ 8 ]===================USB /CF card /pci card ===============================
cd /test/s2r/config
if ! source ./usb_chk.sh ; then
  itemfail "Load usb_chk.sh FAIL !!!"
  show_exit
fi

if ! source ./cf_card_chk.sh ; then
  itemfail "Load cf_card_chk.sh FAIL !!!"
  show_exit
fi

if ! source ./pci_card_check.sh ; then
  itemfail "Load pci_card_chk.sh FAIL !!!"
  show_exit
fi

# [ 9 ]=============================== Hdd Check ===============================
cd /test/s2r/hdd
if [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
  if ! source ./_1S2RUBZ0ST3.sh ; then
    itemfail "Load hdd_chk.sh FAIL !!!"
    show_exit
  fi
else 
  if ! source ./hdd_chk.sh ; then
    itemfail "Load hdd_chk.sh FAIL !!!"
    show_exit
  fi
fi

# [ 10 ]=====================   bbu check ======================================
cd /test/s2r/bbu
if ! source ./bbu_num_chk.sh ; then
  itemfail "Load bbu_num_chk.sh FAIL !!!"
  show_exit
fi

# [ 11 ]=====================   UUID and BMC Mac check    =======================
cd /test/s2r/config
if ! source ./uuid_chk.sh ; then
  itemfail "Load uuid_chk.sh FAIL !!!"
  show_exit
fi

# [ 12 ]============================= LAN MAC Check   ===========================
if ! source ./lanmac_chk.sh ; then
  itemfail "Load lanmac_chk.sh FAIL !!!"
  show_exit
fi

# [ 13 ]============================= LOM Firmware Check ========================
if ! source ./lom_fw_chk.sh ; then
  itemfail "Load lom_fw_chk.sh FAIL !!!"
  show_exit
fi

# [ 14 ]============================ FAN test check ============================
cd /test/s2r/bmc
if ! source ./fan_test.sh; then
  itemfail "Load fan_test.sh FAIL !!!"
  show_exit
fi

# [ 15 ]===========================P3V bat voltage test ========================
if ! source ./voltage.sh; then
  itemfail "Loade voltage.sh FAIL !!!"
  show_exit
fi

# [ 16 ]==========================QCIxDiag test ================================
cd /test/s2r/QCILxDiag_V10
rm -f Output.log
if ! source diag6.sh  ; then
  itemfail "load diag6.sh fail !!!"
  show_exit
fi
retstr=`egrep -i 'FAIL' Output.log`
  if [ ! -z "$retstr" ]; then
    print_red "qcixdiag test fail" |tee -a $Logfile    
    export linuxdiag=FAIL
		itemfail "$retstr !!!" |tee -a $Logfile
    show_exit
  else
    print_green "qcixdiag test pass" |tee -a $Logfile     
    export linuxdiag=PASS
    itempass "qcixdiag test pass !!!" |tee -a $Logfile
  fi
  
#[ 17 ]============================ PING BMC port test==========================
cd /test/s2r/bmc
if ! source ./ping_test.sh ; then
  itemfail "ping test FAIL"
  show_exit
fi


# [ 18 ]============================ clear SEL log =============================
#record sel log
echo "-----record sel log to testlog------" >>$Logfile
ipmitool sel elist -v >>$Logfile
echo "------------------------------------" >>$Logfile
echo "" >>$Logfile
echo "--record sdr list to test log-------" >>$Logfile
ipmitool sdr list >>$Logfile
echo "------------------------------------" >>$Logfile
# [ 19 ]=============================sel check =================================
if ! source ./sel_chk.sh ;then
  itemfail "Sel check FAIL"
  show_exit
fi

ipmitool sel clear
sleep 2
print_green "Clear BMC Event Log OK" |tee -a $Logfile