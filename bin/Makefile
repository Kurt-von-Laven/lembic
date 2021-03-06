#
# A simple makefile for managing build of project composed of C source files.
#
# Julie Zelenski, for CS107, Sept 2009
#

# It is likely that default C compiler is already gcc, but explicitly
# set, just to be sure
CC = gcc

# The CFLAGS variable sets compile flags for gcc:
#  -g          compile with debug information
#  -Wall       give all diagnostic warnings
#  -pedantic   require compliance with ANSI standard
#  -f...       fine-grained optimization instructions that don't introduce
#              vulnerabilities to timing attacks
#  -std=gnu99  use the Gnu C99 standard language definition
#  -D_GNU_SOURCE use GNU library extension
CFLAGS = -g -Wall -pedantic -fcprop-registers -fguess-branch-probability \
  -fif-conversion -fif-conversion2 \
  -fthread-jumps -fcaller-saves -fcse-follow-jumps \
  -fcse-skip-blocks -fdelete-null-pointer-checks -fgcse -fgcse-lm -fgcse-sm \
  -fgcse-las -fgcse-after-reload -fregmove -freorder-blocks \
  -frerun-cse-after-loop -fsched-spec-load -fschedule-insns -fschedule-insns2 \
  -fstrict-aliasing -std=gnu99 -D_GNU_SOURCE

# In this section, you list the files that are part of the project.
# If you add/change names of header/source files, here is where you
# edit the Makefile.
SOURCES = secure_str_cmp.c
OBJECTS = $(SOURCES:.c=.o)
TARGET = secure_str_cmp

# The first target defined in the makefile is the one
# used when make is invoked with no argument. Given the definitions
# above, this Makefile file will build the one named TARGET and
# assume that it depends on all the named OBJECTS files.

default: $(TARGET)

$(TARGET) : $(OBJECTS) Makefile.dependencies
	$(CC) $(CFLAGS) -o $@ $(OBJECTS)

# In make's default rules, a .o automatically depends on its .c file
# (so editing the .c will cause recompilation into its .o file).
# The line below creates additional dependencies.

Makefile.dependencies:: $(SOURCES)
	$(CC) $(CFLAGS) -MM $(SOURCES) > Makefile.dependencies

-include Makefile.dependencies

# Phony means not a "real" target, it doesn't build anything
# The phony target "clean" that is used to remove all compiled object files.

.PHONY: clean

clean:
	@rm -f $(TARGET) $(OBJECTS) core Makefile.dependencies
