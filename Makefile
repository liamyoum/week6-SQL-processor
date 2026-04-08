CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c99 -Isrc
SRC := $(wildcard src/*.c)
CORE_SRC := $(filter-out src/main.c,$(SRC))
TARGET := sql_processor
TEST_STEP1_TARGET := test_step1
TEST_TOKENIZER_TARGET := test_tokenizer

.PHONY: all test clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

$(TEST_STEP1_TARGET): tests/test_step1.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_step1.c $(CORE_SRC) -o $(TEST_STEP1_TARGET)

$(TEST_TOKENIZER_TARGET): tests/test_tokenizer.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_tokenizer.c $(CORE_SRC) -o $(TEST_TOKENIZER_TARGET)

test: $(TARGET) $(TEST_STEP1_TARGET) $(TEST_TOKENIZER_TARGET)
	./$(TEST_STEP1_TARGET)
	./$(TEST_TOKENIZER_TARGET)

clean:
	rm -f $(TARGET) $(TEST_STEP1_TARGET) $(TEST_TOKENIZER_TARGET)
