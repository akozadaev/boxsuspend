TARGET = boxsuspend
SOURCES = $(wildcard *.c)
OBJECTS = $(subst .c$,.o,$(SOURCES))
HEADERS = $(wildcard *.h)
CC = gcc
LINK = gcc
CFLAGS = -Os -std=c99 -pedantic
# CFLAGS += -g -DVERBOSE
LFLAGS = -s
STRIP = strip
INSTALL = install
INSTALL_ARGS = -o root -g wheel -m 4755  # Installs with SUID set
INSTALL_DIR = /usr/local/bin/

# Autoconfiguration
SUSPENDFILE="/sys/power/state"

-include .depend

$(TARGET): build_host.h $(OBJECTS)
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(LIBPATH) $(LIBS)
	$(STRIP) $(TARGET)

.c.o: $*.h common.h
	$(CC) -c $(CFLAGS) $(DEBUGFLAGS) $(INCPATH) -o $@ $<


# now the program gets autoconfigured in Makefile via build_host.h
build_host.h:
	@echo -n "Generating configuration: "
	@echo "#define BUILD_HOST \"`hostname -f`\"" > build_host.h;
	@echo "#define SUSPENDFILE \"${SUSPENDFILE}\"" >> build_host.h
	@echo DONE

install: $(TARGET)
	$(INSTALL) $(INSTALL_ARGS) $(TARGET) $(INSTALL_DIR)
	@echo "DONE"

uninstall:
	-rm -f $(INSTALL_DIR)$(TARGET)
	@echo "DONE"

clean:
	-rm -f .depend
	-rm -f $(OBJECTS)
	-rm -f *~ core *.core
	-rm -f version.h
	-rm -f $(TARGET)
	-rm -f build_host.h

depend:
.depend: Makefile $(SOURCES) $(HEADERS)
	@if [ ! -f .depend ]; then touch .depend; fi
	@makedepend -Y -f .depend  $(SOURCES) 2>/dev/null
