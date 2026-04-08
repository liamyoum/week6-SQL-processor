CC := gcc
CFLAGS := -Wall -Wextra -Werror -std=c11 -Isrc
SRC := $(wildcard src/*.c)
TARGET := sql_processor

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)
