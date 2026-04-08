#include "sql_file_reader.h"

#include <stdio.h>
#include <stdlib.h>

int read_text_file(const char *path, char **out_contents)
{
    FILE *file;
    long file_size;
    size_t bytes_read;
    char *buffer;

    if (path == NULL || out_contents == NULL) {
        return 1;
    }

    *out_contents = NULL;

    file = fopen(path, "rb");
    if (file == NULL) {
        return 1;
    }

    if (fseek(file, 0L, SEEK_END) != 0) {
        fclose(file);
        return 1;
    }

    file_size = ftell(file);
    if (file_size < 0) {
        fclose(file);
        return 1;
    }

    if (fseek(file, 0L, SEEK_SET) != 0) {
        fclose(file);
        return 1;
    }

    buffer = (char *)malloc((size_t)file_size + 1U);
    if (buffer == NULL) {
        fclose(file);
        return 1;
    }

    bytes_read = fread(buffer, 1U, (size_t)file_size, file);
    if (bytes_read != (size_t)file_size) {
        free(buffer);
        fclose(file);
        return 1;
    }

    buffer[(size_t)file_size] = '\0';

    fclose(file);
    *out_contents = buffer;
    return 0;
}
