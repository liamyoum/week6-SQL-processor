#include "statement_splitter.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

static void initialize_statement_list(StatementList *list)
{
    list->items = NULL;
    list->count = 0;
}

static int append_statement(
    StatementList *list,
    size_t *capacity,
    const char *start,
    size_t length)
{
    char **new_items;
    char *statement;
    size_t new_capacity;

    if (list->count == *capacity) {
        new_capacity = (*capacity == 0U) ? 4U : (*capacity * 2U);
        new_items = (char **)realloc(list->items, new_capacity * sizeof(*new_items));
        if (new_items == NULL) {
            return 1;
        }

        list->items = new_items;
        *capacity = new_capacity;
    }

    statement = (char *)malloc(length + 1U);
    if (statement == NULL) {
        return 1;
    }

    memcpy(statement, start, length);
    statement[length] = '\0';

    list->items[list->count] = statement;
    list->count += 1U;
    return 0;
}

void free_statement_list(StatementList *list)
{
    size_t i;

    if (list == NULL) {
        return;
    }

    for (i = 0; i < list->count; i++) {
        free(list->items[i]);
    }

    free(list->items);
    list->items = NULL;
    list->count = 0;
}

int split_sql_statements(const char *sql_text, StatementList *out_list)
{
    StatementList list;
    size_t capacity;
    size_t statement_start;
    size_t i;

    if (sql_text == NULL || out_list == NULL) {
        return 1;
    }

    initialize_statement_list(&list);
    capacity = 0U;
    statement_start = 0U;
    i = 0U;

    while (1) {
        if (sql_text[i] == ';') {
            size_t trimmed_start = statement_start;

            while (trimmed_start < i &&
                   isspace((unsigned char)sql_text[trimmed_start])) {
                trimmed_start += 1U;
            }

            if (trimmed_start < i) {
                if (append_statement(
                        &list,
                        &capacity,
                        sql_text + trimmed_start,
                        (i - trimmed_start) + 1U) != 0) {
                    free_statement_list(&list);
                    return 1;
                }
            }

            statement_start = i + 1U;
        } else if (sql_text[i] == '\0') {
            size_t tail = statement_start;

            while (tail < i && isspace((unsigned char)sql_text[tail])) {
                tail += 1U;
            }

            if (tail != i) {
                free_statement_list(&list);
                return 1;
            }

            *out_list = list;
            return 0;
        }

        i += 1U;
    }
}
