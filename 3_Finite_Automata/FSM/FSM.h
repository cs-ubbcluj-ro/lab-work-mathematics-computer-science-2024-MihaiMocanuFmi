#ifndef FSM_FSM_H
#define FSM_FSM_H

#include <stdlib.h>

enum fsm_NodeTypes
{
    FSM_TYPE_NOT_SET = 0, FSM_TYPE_START = 1, FSM_TYPE_FINAL = 2, FSM_TYPE_INTERMEDIARY = 3,
};

union fsm_ValueData
{
    u_int64_t valueUnsigned;
    int64_t valueSigned;
    double valueReal;
    char valueChar;
    char *valueString;
};

enum fsm_ValueTag
{
    FSM_VALUE_NOTSET = 0,
    FSM_VALUE_UNSIGNED = 1,
    FSM_VALUE_SIGNED = 2,
    FSM_VALUE_REAL = 3,
    FSM_VALUE_CHAR = 4,
    FSM_VALUE_STRING = 5,
};

struct fsm_Value
{
    enum fsm_ValueTag tag;
    union fsm_ValueData data;
};

struct fsm_Transition
{
    size_t nextStateId;
    struct fsm_Value value;
};

struct fsm_State
{
    size_t id;
    char *name;
    enum fsm_NodeTypes type;

    struct fsm_Transition *transitions;
    size_t transitions_length;
};

struct fsm_FSM
{
    size_t start;
    size_t currentState;

    struct fsm_State *states;
    size_t states_length;

    struct fsm_Value *valueBuffer;
    size_t valueBuffer_length;

    struct fsm_Value *alphabet;
    size_t alphabet_length;
};

struct fsm_FSM *fsm_init();

void fsm_free(struct fsm_FSM *fsm);

size_t fsm_addState(struct fsm_FSM *fsm, enum fsm_NodeTypes type, const char *name);

size_t fsm_state_addTransition(struct fsm_FSM *fsm, size_t stateId, struct fsm_Transition);

struct fsm_Transition fsm_transition(size_t nextStateId, enum fsm_ValueTag tag, union fsm_ValueData data);

#endif //FSM_FSM_H
