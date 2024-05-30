# Final Project
EXE=final

# Main target
all: $(EXE)

#  Msys/MinGW
ifeq "$(OS)" "Windows_NT"
CFLG=-O3 -Wall -DUSEGLEW
LIBS=-lglfw3 -lglew32 -lglu32 -lopengl32 -lm
CLEAN=rm -f *.exe *.o *.a
else
#  OSX
ifeq "$(shell uname)" "Darwin"
CFLG=-O3 -Wall -Wno-deprecated-declarations  -DAPPLE_GL4 -DUSEGLEW
LIBS=-lglfw -lglew -framework Cocoa -framework OpenGL -framework IOKit
#  Linux/Unix/Solaris
else
CFLG=-O3 -Wall
LIBS=-lglfw -lGLU -lGL -lm
endif
#  OSX/Linux/Unix/Solaris
CLEAN=rm -f $(EXE) *.o *.a
endif

# Dependencies
final.o: final.cpp CSCIx239.h
fatal.o: fatal.c CSCIx239.h
errcheck.o: errcheck.c CSCIx239.h
print.o: print.c CSCIx239.h
axes.o: axes.c CSCIx239.h
loadtexbmp.o: loadtexbmp.c CSCIx239.h
loadobj.o: loadobj.c CSCIx239.h
projection.o: projection.c CSCIx239.h
lighting.o: lighting.c CSCIx239.h
elapsed.o: elapsed.c CSCIx239.h
fps.o: fps.c CSCIx239.h
shader.o: shader.c CSCIx239.h
noise.o: noise.c CSCIx239.h
initwin.o: initwin.c CSCIx239.h

#  Create archive
CSCIx239.a:fatal.o errcheck.o print.o axes.o loadtexbmp.o projection.o lighting.o elapsed.o fps.o shader.o noise.o initwin.o
	ar -rcs $@ $^

# Compile rules
.c.o:
	gcc -c $(CFLG)  $<
.cpp.o:
	g++ -c $(CFLG)  $<

#  Link
final:final.o   CSCIx239.a
	g++ $(CFLG) -o $@ $^  $(LIBS)

#  Clean
clean:
	$(CLEAN)
