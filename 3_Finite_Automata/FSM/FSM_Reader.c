#include <string.h>
#include "FSM_Reader.h"

static void remove_spaces(char *s)
{
    char *d = s;
    do
    {
        while (*d == ' ')
        {
            ++d;
        }
    } while (*s++ = *d++);
}
static struct fsm_FSM *error_exit(int wantedError, int *errorCode, struct fsm_FSM **fsm, char **line)
{
    *errorCode = -1;

    free(*line);
    *line = NULL;

    free(*fsm);
    *fsm = NULL;

    return NULL;
}

struct fsm_FSM *fsm_reader_construct(const char *file, int *errorCode)
{
    /// TODO: trim whitespace
    /// TODO: Refactor it, generalize the behaviour, maybe use a state machine to parse all the sections.

    FILE *fp;
    fp = fopen(file, "r");
    if (fp == NULL)
    {
        *errorCode = -1;
        return NULL;
    }

    char *line = NULL;
    size_t line_len = 0;
    ssize_t readChs;
    while ((readChs = getline(&line, &line_len, fp)) != -1 && strcmp(line, "#STATES:\n") != 0 &&
           strcmp(line, "#STATES:") != 0)
    {
        printf("Skipping line of length %zu:\t%s\n", readChs, line);
    }
    struct fsm_FSM *fsm = fsm_init();
    if (readChs == -1)
        return error_exit(-1, errorCode, &fsm, &line);

    printf("Jumping over line:\t%s\n", line);
    while ((readChs = getline(&line, &line_len, fp)) != -1 && strcmp(line, "#TRANSITIONS:\n") != 0 &&
           strcmp(line, "#TRANSITIONS:") != 0)
    {
        printf("Parsing line of length %zu:\t%s\n", readChs, line);
        if (!strchr(line, ';'))
        {
            printf("\tCould not find ending: ';'. Jumping over.\n");
            continue;
        }
        char *tempLine = strdup(line);
        char *stateType_start = tempLine;
        char *stateType_end = strchr(tempLine, ',');
        *stateType_end = '\0';
        printf("\tFound state type:\t\"%s\"\n", stateType_start);

        char *stateName_start = stateType_end + 2;
        char *stateName_end = strchr(stateName_start, ';');
        *stateName_end = '\0';
        printf("\tFound state name:\t\"%s\"\n\n", stateName_start);

        fsm_addState(fsm, atoi(stateType_start), stateName_start);
        free(tempLine);
    }
    if (readChs == -1)
        return error_exit(-1, errorCode, &fsm, &line);

    printf("Jumping over line:\t%s\n", line);
    size_t stateIdCount = 0;
    while ((readChs = getline(&line, &line_len, fp)) != -1 && strcmp(line, "#END;\n") != 0 &&
           strcmp(line, "#END;") != 0)
    {
        printf("Parsing line of length %zu:\t%s\n", readChs, line);
        char *line_end = strchr(line, ';');
        if (!line_end)
        {
            printf("\tCould not find ending: ';'. Jumping over.\n\n");
            continue;
        }
        if (line_end == line)
        {
            printf("\tEmpty transition statement.\n\n");
            stateIdCount++;
            continue;
        }
        *line_end = '\0';
        for (char *group = strtok(line, "|;"); group != NULL; group = strtok(NULL, "|;"))
        {
            remove_spaces(group);
            printf("\tIdentified group:\t\"%s\"\n", group);
            char *el1_start = group;
            char *el1_end = strchr(group, ',');
            if (!el1_end)
                return error_exit(-1, errorCode, &fsm, &line);
            *el1_end = '\0';
            printf("\t\tIdentified transitions next state id:\t\"%s\"\n", el1_start);
            size_t nextStateId = atoi(el1_start);

            char *el2_start = el1_end + 1;
            char *el2_end = strchr(el2_start, ',');
            if (!el2_end)
                return error_exit(-1, errorCode, &fsm, &line);
            *el2_end = '\0';
            printf("\t\tIdentified transitions value tag:\t\"%s\"\n", el2_start);
            enum fsm_ValueTag tag = atoi(el2_start);

            char *el3_start = el2_end + 1;
            char *el3_end = el3_start + strlen(el3_start);
            if (!el3_end)
                return error_exit(-1, errorCode, &fsm, &line);
            *el3_end = '\0'; // useless operation as it's already null terminated.
            printf("\t\tIdentified transitions value:\t\"%s\"\n", el3_start);
            union fsm_ValueData data;
            switch (tag)
            {
                case FSM_VALUE_NOTSET:
                    printf("\t\tInterpreting as NOTSET.\n");
                    break;
                case FSM_VALUE_UNSIGNED:
                    /// TODO strtoul
                    printf("\t\tInterpreting as UNSIGNED.\n");
                    data.valueUnsigned = atoll(el3_start);
                    break;
                case FSM_VALUE_SIGNED:
                    printf("\t\tInterpreting as SIGNED.\n");
                    data.valueSigned = atoll(el3_start);
                    break;
                case FSM_VALUE_REAL:
                    printf("\t\tInterpreting as REAL.\n");
                    data.valueReal = atof(el3_start);
                    break;
                case FSM_VALUE_CHAR:
                    printf("\t\tInterpreting as CHAR.\n");
                    data.valueChar = *el3_start;
                    break;
                case FSM_VALUE_STRING:
                    printf("\t\tInterpreting as STRING.\n");
                    data.valueString = strdup(el3_start);
                    break;
            }
            fsm_state_addTransition(fsm, stateIdCount, fsm_transition(nextStateId, tag, data));
        }
        stateIdCount++;
        printf("\n");

    }
    printf("Jumping over line:\t%s\n", line);
    printf("Finished!\n");
    fclose(fp);
    if (line)
        free(line);
    return fsm;
}
