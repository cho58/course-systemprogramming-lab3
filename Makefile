# Compiler and options
CC = gcc800
CFLAGS = -std=gnu99
TESTFLAGS = -O0 -g
TIMEFLAGS = -O3 -D NDEBUG

# Directory paths
REFERENCE_DIR = reference
SRC_DIR = src
TEST_DIR = test

# File definitions
TEST = $(TEST_DIR)/testheapmgr.c
CHUNK_BASE = $(REFERENCE_DIR)/chunkbase.c
CHUNK_BASE_H = $(REFERENCE_DIR)/chunkbase.h
HEAPMGR_H = $(REFERENCE_DIR)/heapmgr.h
HEAPMGR_GNU = $(REFERENCE_DIR)/heapmgrgnu.c
HEAPMGR_KR = $(REFERENCE_DIR)/heapmgrkr.c
HEAPMGR_BASE = $(REFERENCE_DIR)/heapmgrbase.c
HEAPMGR1 = $(SRC_DIR)/heapmgr1.c
HEAPMGR2 = $(SRC_DIR)/heapmgr2.c
CHUNK = $(SRC_DIR)/chunk.c
CHUNK_H = $(SRC_DIR)/chunk.h

# Build history
HIST = history
PREV = $(HIST)/_prev
LOG = $(HIST)/build.log
CTR = $(HIST)/.counter
TRACKED = $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/*.h)
MAKEFILE_MD5 = $(shell md5sum Makefile 2>/dev/null | cut -d' ' -f1)

# Each public build target records one source diff and one build result.
all:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_time1all

test1:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_test1

test2:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_test2

testall:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_testall

timegnu:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_timegnu

timekr:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_timekr

timebase:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_timebase

time1:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_time1

time2:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_time2

time1all:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_time1all

time2all:
	@$(MAKE) --no-print-directory _track BUILD_TARGET=_build_time2all

_track:
	@mkdir -p $(HIST) $(PREV)
	@[ -f $(CTR) ] || echo 0 > $(CTR)
	@N=$$(cat $(CTR)); \
	 NEXT=$$((N + 1)); \
	 PAD=$$(printf '%04d' $$NEXT); \
	 if [ $$N -gt 0 ]; then \
	   diff -ruN $(PREV) $(SRC_DIR) > $(HIST)/$$PAD.diff 2>/dev/null || true; \
	   DA=$$(grep -c '^+[^+]' $(HIST)/$$PAD.diff 2>/dev/null || true); \
	   DR=$$(grep -c '^-[^-]' $(HIST)/$$PAD.diff 2>/dev/null || true); \
	   [ -n "$$DA" ] || DA=0; [ -n "$$DR" ] || DR=0; \
	   echo "[diff] +$$DA -$$DR"; \
	 else \
	   if [ -n "$(strip $(TRACKED))" ]; then \
	     wc -l $(TRACKED) > $(HIST)/$$PAD.diff 2>/dev/null; \
	   else \
	     : > $(HIST)/$$PAD.diff; \
	   fi; \
	   echo "[diff] initial"; \
	 fi; \
	 rm -rf $(PREV)/*; \
	 cp $(TRACKED) $(PREV)/ 2>/dev/null || true; \
	 $(MAKE) --no-print-directory $(BUILD_TARGET) 2> $(HIST)/.tmp; \
	 EXIT=$$?; \
	 if [ $$EXIT -eq 0 ]; then \
	   echo "[make] ✓ build succeeded"; RES=SUCCESS; \
	 else \
	   echo "[make] ✗ build failed:"; cat $(HIST)/.tmp; RES=FAIL; \
	 fi; \
	 ERR=$$(grep -ci ' error:' $(HIST)/.tmp 2>/dev/null || true); \
	 WRN=$$(grep -ci ' warning:' $(HIST)/.tmp 2>/dev/null || true); \
	 [ -n "$$ERR" ] || ERR=0; [ -n "$$WRN" ] || WRN=0; \
	 TS=$$(date '+%Y-%m-%d_%H:%M:%S'); \
	 SL=$$(for F in $(TRACKED); do cat "$$F"; done 2>/dev/null | wc -l | tr -d ' '); \
	 echo "$$PAD $$TS $$RES $$ERR $$WRN $$SL $(MAKEFILE_MD5)" >> $(LOG); \
	 echo $$NEXT > $(CTR); \
	 rm -f $(HIST)/.tmp; \
	 echo "[history] #$$PAD recorded"; \
	 exit $$EXIT

# Internal build targets. Public targets above add history around these commands.
_build_test1:
	$(CC) $(CFLAGS) $(TESTFLAGS) $(TEST) $(HEAPMGR1) $(CHUNK) -o $(TEST_DIR)/testheapmgr1

_build_test2:
	$(CC) $(CFLAGS) $(TESTFLAGS) $(TEST) $(HEAPMGR2) $(CHUNK) -o $(TEST_DIR)/testheapmgr2

_build_testall: _build_test1 _build_test2

_build_timegnu:
	$(CC) $(TIMEFLAGS) $(CFLAGS) $(TEST) $(HEAPMGR_GNU) -o $(TEST_DIR)/testheapmgrgnu

_build_timekr:
	$(CC) $(TIMEFLAGS) $(CFLAGS) $(TEST) $(HEAPMGR_KR) -o $(TEST_DIR)/testheapmgrkr

_build_timebase:
	$(CC) $(TIMEFLAGS) $(CFLAGS) $(TEST) $(HEAPMGR_BASE) $(CHUNK_BASE) -o $(TEST_DIR)/testheapmgrbase

_build_time1:
	$(CC) $(TIMEFLAGS) $(CFLAGS) $(TEST) $(HEAPMGR1) $(CHUNK) -o $(TEST_DIR)/testheapmgr1

_build_time2:
	$(CC) $(TIMEFLAGS) $(CFLAGS) $(TEST) $(HEAPMGR2) $(CHUNK) -o $(TEST_DIR)/testheapmgr2

_build_time1all: _build_timegnu _build_timekr _build_timebase _build_time1

_build_time2all: _build_timegnu _build_timekr _build_timebase _build_time1 _build_time2

# Build history summary
status:
	@if [ ! -f $(LOG) ]; then \
	   echo "No history yet."; \
	 else \
	   echo ""; \
	   printf "  %-6s %-20s %-8s %-4s %-5s %-6s\n" \
	     "#" "Timestamp" "Result" "Err" "Warn" "Lines"; \
	   echo "  ─────────────────────────────────────────────────────"; \
	   while read NUM TS RES ERR WRN SL MD5; do \
	     printf "  %-6s %-20s %-8s %-4s %-5s %-6s\n" \
	       "$$NUM" "$$TS" "$$RES" "$$ERR" "$$WRN" "$$SL"; \
	   done < $(LOG); \
	   echo "  ─────────────────────────────────────────────────────"; \
	   TOTAL=$$(wc -l < $(LOG) | tr -d ' '); \
	   SUCC=$$(grep -c SUCCESS $(LOG) || true); \
	   FAIL=$$(grep -c FAIL $(LOG) || true); \
	   [ -n "$$SUCC" ] || SUCC=0; \
	   [ -n "$$FAIL" ] || FAIL=0; \
	   echo "  Total: $$TOTAL  |  Success: $$SUCC  |  Fail: $$FAIL"; \
	   echo ""; \
	 fi

# Clean build products, but keep history.
clean:
	rm -f $(TEST_DIR)/testheapmgrgnu $(TEST_DIR)/testheapmgrkr $(TEST_DIR)/testheapmgrbase $(TEST_DIR)/testheapmgr1 $(TEST_DIR)/testheapmgr2

.PHONY: all test1 test2 testall timegnu timekr timebase time1 time2 \
	time1all time2all _track _build_test1 _build_test2 _build_testall \
	_build_timegnu _build_timekr _build_timebase _build_time1 \
	_build_time2 _build_time1all _build_time2all status clean
