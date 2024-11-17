#include <stdio.h>

#include "FSM.h"
#include "FSM_Reader.h"
#include "FSM_Parse.h"

int main(void)
{
    int error;
    struct fsm_FSM *fsm = fsm_reader_construct("../fsm.in", &error);

    printf("Alphabet (value, tag):\n");
    for (size_t i = 0; i < fsm->alphabet_length; ++i)
    {
        printf("(%ld, %d), ", fsm->alphabet[i].data.valueSigned, fsm->alphabet[i].tag);
    }
    printf("\n");
    printf("STATES:\n");
    for (size_t i = 0; i < fsm->states_length; ++i)
    {
        printf("State id:%zu, name:\"%s\", type:%d\n", fsm->states[i].id, fsm->states[i].name, fsm->states[i].type);
        printf("\tTransitions (nextStateId, value): ");
        for (size_t j = 0; j < fsm->states[i].transitions_length; ++j)
        {
            printf("(%zu, %ld), ", fsm->states[i].transitions[j].nextStateId,
                   fsm->states[i].transitions[j].value.data.valueSigned);
        }
        printf("\n");
    }
    fsm_free(fsm);

    fsm = fsm_reader_construct("../Bonus/VOID.in", &error);
    if (fsm_parse_chr(fsm, "void"))
    {
        printf("\"void\" is a VOID token\n");
    }
    else
    {
        printf("Unexpected result\n");
    }

    if (!fsm_parse_chr(fsm, "notvoid") && !fsm_parse_chr(fsm, "voidnot"))
    {
        printf("Both \"notvoid\" and \"voidnot\" are not VOID tokens\n");
    }
    else
    {
        printf("Unexpected result\n");
    }
    fsm_free(fsm);
    return 0;
}
