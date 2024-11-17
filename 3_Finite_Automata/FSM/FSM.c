#include "FSM.h"

#include <stdbool.h>
#include <math.h>
#include <string.h>


struct fsm_FSM *fsm_init()
{
    struct fsm_FSM *fsm = calloc(1, sizeof(struct fsm_FSM));
    return fsm;
}

void fsm_free(struct fsm_FSM *fsm)
{
    for (size_t i = 0; i < fsm->states_length; ++i)
    {
        struct fsm_State *state = &fsm->states[i];
        free(state->name);

        for (size_t j = 0; j < state->transitions_length; ++j)
        {
            struct fsm_Transition *transition = &state->transitions[j];
            if (transition->value.tag == FSM_VALUE_STRING)
            {
                free(transition->value.data.valueString);
                transition->value.data.valueString = NULL;
            }
        }
        free(state->transitions);
        state->transitions = NULL;
        state->transitions_length = 0;
    }
    free(fsm->states);
    fsm->states = NULL;
    fsm->states_length = 0;

    free(fsm->valueBuffer);
    fsm->valueBuffer = NULL;
    fsm->valueBuffer_length = 0;

    free(fsm->alphabet);
    fsm->alphabet = NULL;
    fsm->alphabet_length = 0;

    free(fsm);
}

size_t fsm_addState(struct fsm_FSM *fsm, enum fsm_NodeTypes type, const char *name)
{
    struct fsm_State *result = realloc(fsm->states, (fsm->states_length + 1) * sizeof(struct fsm_State));
    if (!result)
        return -1;
    fsm->states = result;
    size_t index = fsm->states_length;
    fsm->states[index] = (struct fsm_State) {.id = index, .type = type, .name = strdup(name),};
    fsm->states_length++;

    fsm->states[index].transitions = NULL;
    fsm->states[index].transitions_length = 0;
    return index;
}

static bool areValueDataEqual(const struct fsm_Value *lhs, const struct fsm_Value *rhs)
{
    if (lhs->tag == rhs->tag)
    {
        switch (lhs->tag)
        {
            case FSM_VALUE_NOTSET:
                return true;
            case FSM_VALUE_UNSIGNED:
                return lhs->data.valueUnsigned == rhs->data.valueUnsigned;
            case FSM_VALUE_SIGNED:
                return lhs->data.valueSigned == rhs->data.valueSigned;
            case FSM_VALUE_REAL:
                return fabs(lhs->data.valueReal - rhs->data.valueReal) < 0.00001;
            case FSM_VALUE_CHAR:
                return lhs->data.valueChar == rhs->data.valueChar;
            case FSM_VALUE_STRING:
                return strcmp(lhs->data.valueString, rhs->data.valueString) == 0;
            default:
                return false;
        }
    }
    return false;
}

static size_t update_alphabet(struct fsm_FSM *fsm, const struct fsm_Value *value)
{
    for (size_t i = 0; i < fsm->alphabet_length; ++i)
    {
        if (areValueDataEqual(&fsm->alphabet[i], value))
            return i;
    }
    struct fsm_Value *result = realloc(fsm->alphabet, (fsm->alphabet_length + 1) * sizeof(struct fsm_Value));
    if (!result)
        return -1;
    fsm->alphabet = result;
    size_t index = fsm->alphabet_length;
    fsm->alphabet[index] = *value;
    fsm->alphabet_length++;
    return index;
}

size_t fsm_state_addTransition(struct fsm_FSM *fsm, size_t stateId, struct fsm_Transition transition)
{
    struct fsm_State *parent = &fsm->states[stateId];
    struct fsm_Transition *result = realloc(parent->transitions,
                                            (parent->transitions_length + 1) * sizeof(struct fsm_Transition));
    if (!result)
        return -1;
    parent->transitions = result;
    size_t index = parent->transitions_length;
    parent->transitions[index] = transition;
    parent->transitions_length++;

    update_alphabet(fsm, &transition.value);
    return index;
}

struct fsm_Transition fsm_transition(size_t nextStateId, enum fsm_ValueTag tag, union fsm_ValueData data)
{
    struct fsm_Transition transition = {.nextStateId = nextStateId, (struct fsm_Value) {.tag = tag, .data = data,}};
    return transition;
}
