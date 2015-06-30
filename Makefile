#****************************************************************************
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#****************************************************************************

SRC     = src
INC     = -I. -I../.. 
RT      = NO_RT
 
DBG = DEBUG

ifeq ($(RT), XENOMAI)
SKIN = xeno
### Xenomai directory, xeno-config and library directory ###########
RT_DIR          ?= /usr/xenomai
RT_CONFIG       ?= $(RT_DIR)/bin/xeno-config
RT_LIB_DIR      ?= $(shell $(RT_CONFIG) --library-dir) -Wl,-rpath $(shell $(RT_CONFIG) --library-dir)
### User space application compile options #########################
USERAPP_LIBS      ?= -lnative -lpcan
USERAPP_LDFLAGS   ?= $(shell $(RT_CONFIG) --$(SKIN)-ldflags) -L$(RT_LIB_DIR)
USERAPP_CFLAGS    ?= $(shell $(RT_CONFIG) --$(SKIN)-cflags)
endif

ifeq ($(RT), RTAI)
SKIN = lxrt
### Rtai directory, rtai-config and library directory ###########
RT_DIR          ?= /usr/realtime
RT_CONFIG       ?= $(RT_DIR)/bin/rtai-config
RT_LIB_DIR      ?= $(shell $(RT_CONFIG) --library-dir) -Wl,-rpath $(shell $(RT_CONFIG) --library-dir)
### User space application compile options #########################
USERAPP_LIBS      ?= -llxrt -lpcan
USERAPP_LDFLAGS   ?= $(shell $(RT_CONFIG) --$(SKIN)-ldflags) -L$(RT_LIB_DIR)
USERAPP_CFLAGS    ?= $(shell $(RT_CONFIG) --$(SKIN)-cflags)
endif

ifeq ($(RT), NO_RT)
  USERAPP_LIBS = -lpcanbasic -lpthread
endif

ifeq ($(HOSTTYPE),x86_64)
  LDLIBS  = -L../lib -L/lib64 -L/usr/lib64 -L/usr/local/lib64
else
  LDLIBS  = -L../lib -L/lib -L/usr/lib -L/usr/local/lib
endif

# enabling corss-compile from ../Makefile
ifneq ($(CROSS_COMPILE),)
  LDLIBS  = -L../lib
endif

ifneq ($(RT), NO_RT)
DBGFLAGS   =
else
DBGFLAGS   = -g 
endif

ifeq ($(DBG), DEBUG)
CFLAGS  = $(DBGFLAGS) $(INC) $(LDLIBS)
else
CFLAGS  = $(INC) $(LDLIBS)
endif

TARGET1 = bad
FILES1  = $(SRC)/$(TARGET1).cpp $(SRC)/CANbus.cpp  $(SRC)/BarrettHand.cpp  $(SRC)/HighLevelBAD.cpp  $(SRC)/kinematics.cpp $(SRC)/extra_library.cpp

TARGET2 = bad_logger
FILES2  = $(SRC)/$(TARGET2).cpp $(SRC)/CANbus.cpp  $(SRC)/BarrettHand.cpp  $(SRC)/HighLevelBAD.cpp $(SRC)/kinematics.cpp

TARGET3 = bad_test
FILES3  = $(SRC)/$(TARGET1).cpp $(SRC)/CANbus.cpp  $(SRC)/BarrettHand.cpp  $(SRC)/HighLevelBAD.cpp  $(SRC)/kinematics.cpp $(SRC)/extra_library.cpp $(SRC)/admittance.cpp



all:    $(TARGET1) $(TARGET2) $(TARGET3)
#$(TARGET3)

$(TARGET1): $(FILES1)
	g++ $(FILES1) $(CFLAGS) -o $(TARGET1) $(USERAPP_CFLAGS) $(USERAPP_LDFLAGS) $(USERAPP_LIBS) -D$(RT) 
	
$(TARGET2): $(FILES2)
	g++ $(FILES2) $(CFLAGS) -o $(TARGET2) $(USERAPP_CFLAGS) $(USERAPP_LDFLAGS) $(USERAPP_LIBS) -D$(RT) 

$(TARGET3): $(FILES3)
	g++ $(FILES2) $(CFLAGS) -o $(TARGET2) $(USERAPP_CFLAGS) $(USERAPP_LDFLAGS) $(USERAPP_LIBS) -D$(RT) 

clean:
	rm -f $(SRC)/*~ $(SRC)/*.o *~ $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4) $(TARGET5)
	
install:
	cp $(TARGET1) /usr/local/bin




