#include "sql_file_reader.h"
#include "statement_splitter.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    const char *sql_file_path;
    char *sql_text;
    StatementList statements;
    size_t i;

    if (argc != 2) {
        fprintf(stderr, "usage: %s <sql_file_path>\n", argv[0]);
        return 1;
    }

    sql_file_path = argv[1];
    sql_text = NULL;
    statements.items = NULL;
    statements.count = 0U;

    if (read_text_file(sql_file_path, &sql_text) != 0) {
        fprintf(stderr, "failed to read sql file: %s\n", sql_file_path);
        return 1;
    }

    if (split_sql_statements(sql_text, &statements) != 0) {
        fprintf(stderr, "failed to split statements: every statement must end with ';'\n");
        free(sql_text);
        return 1;
    }

    for (i = 0; i < statements.count; i++) {
        printf("%s\n", statements.items[i]);
    }

    free_statement_list(&statements);
    free(sql_text);
    return 0;
}
