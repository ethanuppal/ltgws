# Copyright (C) 2023 Ethan Uppal. All rights reserved.

SRCDIR      := .
SRC         := $(shell find $(SRCDIR) -type f -name "*.swift")
PRG         := main.out
SWIFTC      := swiftc
SWIFT_FLAGS := -O -sdk "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

$(PRG): $(SRC)
	$(SWIFTC) $(SWIFT_FLAGS) $< -o $@

.PHONY clean
clean:
	rm -rf $(PRG)