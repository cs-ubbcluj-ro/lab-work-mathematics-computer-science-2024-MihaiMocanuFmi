cmake_minimum_required(VERSION 3.28)
project(FSM C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_FLAGS_DEBUG  "${CMAKE_C_FLAGS_DEBUG} -O0 -Wall -Wextra -Wpedantic -Wno-unused-variable -Wno-unused-parameter
     -fsanitize=address,undefined")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} -fsanitize=address,undefined")

add_executable(FSM main.c
        FSM.c
        FSM.h
        FSM_Reader.c
        FSM_Reader.h
        FSM_Parse.c
        FSM_Parse.h)
