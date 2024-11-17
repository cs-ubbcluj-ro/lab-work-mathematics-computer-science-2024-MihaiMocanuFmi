#ifndef FSM_FSM_READER_H
#define FSM_FSM_READER_H

#include <stdio.h>

#include "FSM.h"

struct fsm_FSM* fsm_reader_construct(const char *file, int *errorCode);

#endif //FSM_FSM_READER_H
