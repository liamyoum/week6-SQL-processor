CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c99 -Isrc
SRC := $(wildcard src/*.c)
CORE_SRC := $(filter-out src/main.c,$(SRC))
TARGET := sql_processor
TEST_TARGET := test_step1

.PHONY: all test clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

$(TEST_TARGET): tests/test_step1.c $(CORE_SRC)
	$(CC) $(CFLAGS) tests/test_step1.c $(CORE_SRC) -o $(TEST_TARGET)

test: $(TARGET) $(TEST_TARGET)
	./$(TEST_TARGET)

clean:
	rm -f $(TARGET) $(TEST_TARGET)
