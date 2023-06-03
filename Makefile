# Copyright (C) 2023 Ethan Uppal. All rights reserved.

SRCDIR      := src
SRC         := $(shell find $(SRCDIR) -name "*.swift" -type f)
PRG         := main.out
SWIFTC      := swiftc
SWIFT_FLAGS := -O -sdk "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

test: $(PRG) Makefile
	./$(PRG)

$(PRG): $(SRC)
	$(SWIFTC) $(SWIFT_FLAGS) $^ -o $@

.PHONY: clean
clean:
	rm -rf $(PRG) ./.DS_Store ./*.DS_Store ./**/*.DS_Store *.dSYM
