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

    /* Step 1에서는 ./sql_processor <sql_file_path> 형태만 받는다. */
    if (argc != 2) {
        fprintf(stderr, "usage: %s <sql_file_path>\n", argv[0]);
        return 1;
    }

    sql_file_path = argv[1];

    /* 아직 메모리를 받은 적 없는 안전한 초기 상태로 둔다. */
    sql_text = NULL;
    statements.items = NULL;
    statements.count = 0U;

    /* SQL 파일 전체를 하나의 문자열로 읽는다. */
    if (read_text_file(sql_file_path, &sql_text) != 0) {
        fprintf(stderr, "failed to read sql file: %s\n", sql_file_path);
        return 1;
    }

    /* 전체 문자열을 세미콜론 기준으로 문장 여러 개로 나눈다. */
    if (split_sql_statements(sql_text, &statements) != 0) {
        fprintf(stderr, "failed to split statements: every statement must end with ';'\n");
        free(sql_text);
        return 1;
    }

    /* Step 1에서는 해석하지 않고 raw statement를 그대로 출력만 한다. */
    for (i = 0; i < statements.count; i++) {
        printf("%s\n", statements.items[i]);
    }

    /* malloc으로 받은 메모리는 마지막에 직접 해제해야 한다. */
    free_statement_list(&statements);
    free(sql_text);
    return 0;
}
