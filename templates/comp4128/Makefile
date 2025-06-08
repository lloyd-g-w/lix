CXX = g++
CPPFLAGS = -Wall -Wextra -Wshadow -Wformat=2 -Wfloat-equal -Wconversion -Wlogical-op \
           -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 \
           -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector \
           -O2 --std=c++17 -g

SRC = $(wildcard *.cpp)
OBJ = $(SRC:.cpp=.o)
TARGET = main

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(CPPFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CPPFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)

