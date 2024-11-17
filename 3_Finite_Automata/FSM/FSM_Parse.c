#include "FSM_Parse.h"

bool fsm_parse_chr(struct fsm_FSM *fsm, const char *input)
{
    fsm->currentState = fsm->start;
    const char *p = input;
    while (true)
    {
        bool foundNext = false;
        for (size_t i = 0; i < fsm->states[fsm->currentState].transitions_length; ++i)
        {
            const struct fsm_Transition *currentTransition = &fsm->states[fsm->currentState].transitions[i];
            if (currentTransition->value.data.valueChar == *p)
            {
                fsm->currentState = currentTransition->nextStateId;
                p++;
                foundNext = true;
                //we assume that the state machine is deterministic
                break;
            }
        }
        if (!foundNext)
        {
            return false;
        }
        else if (*p == '\0')
        {
            return fsm->states[fsm->currentState].type == FSM_TYPE_FINAL;
        }
    }
}
