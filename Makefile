CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c99 -Isrc
SRC := $(wildcard src/*.c)
CORE_SRC := $(filter-out src/main.c,$(SRC))
TARGET := sql_processor
TEST_STEP1_TARGET := test_step1
TEST_TOKENIZER_TARGET := test_tokenizer
TEST_PARSER_TARGET := test_parser
TEST_DATETIME_UTILS_TARGET := test_datetime_utils
TEST_STUDENT_STORAGE_TARGET := test_student_storage
TEST_ENTRY_LOG_STORAGE_TARGET := test_entry_log_storage
TEST_STEP4_TARGET := test_step4
TEST_STEP5_TARGET := test_step5

.PHONY: all test clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

$(TEST_STEP1_TARGET): tests/test_step1.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_step1.c $(CORE_SRC) -o $(TEST_STEP1_TARGET)

$(TEST_TOKENIZER_TARGET): tests/test_tokenizer.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_tokenizer.c $(CORE_SRC) -o $(TEST_TOKENIZER_TARGET)

$(TEST_PARSER_TARGET): tests/test_parser.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_parser.c $(CORE_SRC) -o $(TEST_PARSER_TARGET)

$(TEST_DATETIME_UTILS_TARGET): tests/test_datetime_utils.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_datetime_utils.c $(CORE_SRC) -o $(TEST_DATETIME_UTILS_TARGET)

$(TEST_STUDENT_STORAGE_TARGET): tests/test_student_storage.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_student_storage.c $(CORE_SRC) -o $(TEST_STUDENT_STORAGE_TARGET)

$(TEST_ENTRY_LOG_STORAGE_TARGET): tests/test_entry_log_storage.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_entry_log_storage.c $(CORE_SRC) -o $(TEST_ENTRY_LOG_STORAGE_TARGET)

$(TEST_STEP4_TARGET): tests/test_step4.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_step4.c $(CORE_SRC) -o $(TEST_STEP4_TARGET)

$(TEST_STEP5_TARGET): tests/test_step5.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_step5.c $(CORE_SRC) -o $(TEST_STEP5_TARGET)

test: $(TARGET) $(TEST_STEP1_TARGET) $(TEST_TOKENIZER_TARGET) $(TEST_PARSER_TARGET) $(TEST_DATETIME_UTILS_TARGET) $(TEST_STUDENT_STORAGE_TARGET) $(TEST_ENTRY_LOG_STORAGE_TARGET) $(TEST_STEP4_TARGET) $(TEST_STEP5_TARGET)
	./$(TEST_STEP1_TARGET)
	./$(TEST_TOKENIZER_TARGET)
	./$(TEST_PARSER_TARGET)
	./$(TEST_DATETIME_UTILS_TARGET)
	./$(TEST_STUDENT_STORAGE_TARGET)
	./$(TEST_ENTRY_LOG_STORAGE_TARGET)
	./$(TEST_STEP4_TARGET)
	./$(TEST_STEP5_TARGET)

clean:
	rm -f $(TARGET) $(TEST_STEP1_TARGET) $(TEST_TOKENIZER_TARGET) $(TEST_PARSER_TARGET) $(TEST_DATETIME_UTILS_TARGET) $(TEST_STUDENT_STORAGE_TARGET) $(TEST_ENTRY_LOG_STORAGE_TARGET) $(TEST_STEP4_TARGET) $(TEST_STEP5_TARGET)
