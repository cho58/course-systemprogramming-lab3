# Lab 3: Dynamic Memory Manager Module

## Purpose

The purpose of this assignment is to help you understand how dynamic memory management works in C. It also will give you more opportunity to use the GNU/Unix programming tools.

## Important Dates

| Date | Description |
|:---  |:--- |
| Monday, November 2, 21:00 | Submission deadline |

## Overview

### Hand-out

Please read this file (README.md) carefully. It is the authoritative specification for this assignment.

The assignment starts by extracting the provided assign3.tar.gz file. It is recommended that you link this folder to your GitHub repository (for better readability of the README file and keep your code safe).

### Submission

As in lab 1 and lab 2, create a directory named after your student number, zip it up, and submit it. And, be sure to follow the following directory structure:

```
202600000_assign3
  |-heapmgr1.c
  |-heapmgr2.c (optional)
  |-chunk.c
  |-chunk.h
  |-history/*
  `-readme
```

**Important:** Please be sure to submit the entire `history` directory. We want to emphasize once again that we take a strict stance regarding AI usage every semester. The `history` directory will serve as strong evidence that you completed the assignment without using AI. Conversely, failing to submit it could lead to suspicions that you used AI.

### Implementing the Lab on an M1/M2 Mac or custom Unix/Linux

While it is possible to implement the lab on an ARM-based Mac, MacOS is not 100% compatible with Linux and thus requires a number of changes to the code (extra header files, etc.) We recommend installing an ARM-based Linux virtual machine such as [Ubuntu Server for ARM](https://ubuntu.com/download/server/arm). On custom Intel-compatible Linux systems, you should be able to implement the lab without any modifications.

Note that we evaluate your submissions in the provided Bacchus VMs. If you do not use the Bacchus VMs to develop your code, **we strongly recommend testing your submission in the Bacchus VMs** to make sure it runs correctly.

## Your task

You are given the interface of a `heapmgr` (heap manager) module in a file named `heapmgr.h`. It declares two functions:
```
void *heapmgr_malloc(size_t ui_bytes);
void  heapmgr_free(void *pv_bytes);
```
You also are given three implementations of the heapmgr module:

* `heapmgrgnu.c` is an implementation that simply calls the GNU `malloc()` and `free()` functions provided with our lab machine development environment.
* `heapmgrkr.c` is the Kernighan and Ritchie (K&R) implementation, with small modifications for the sake of simplicity.
* `heapmgrbase.c` is an implementation that you will find useful as a baseline for your implementations.

Your task is to create an implementation (or two implementations) of the `heapmgr` module.  
Your implementation, **`heapmgr1.c`**, can be based on `heapmgrbase.c`, but should be more efficient.
To do that it should use a single doubly-linked list and blocks that contain headers and footers (as described in lectures, and in precepts).  
Unlike the K&R implementation, the baseline code uses a **non-circular** list, and your code should implement a **doubly-linked** list. (You can implement either **circular** or **non-circular**)

In `heapmgr1.c`, `heapmgr_malloc()` must use **first-fit**: search the free list from its head and select the first block large enough to satisfy the request.

If designed properly, `heapmgr1.c` will be reasonably efficient in most cases.  
However, `heapmgr1.c` is subject to poor worst-case behavior. An additional implementation, **`heapmgr2.c`**, should enhance `heapmgr1.c` so the worst-case behavior is not poor.  
To do that it should use **multiple doubly-linked lists**, a.k.a. **bins** (as described in lectures, and in precepts).  
Note that implementing `heapmgr2.c` is **not mandatory**, and you can get full marks without the implementation of `heapmgr2.c`; Instead, you will get **extra credit** if you implement `heapmgr2.c`.  

Your `heapmgr` implementations should not call the standard `malloc()`, `free()`, `calloc()`, or `realloc()` functions.
Your implementations must obtain additional heap memory through `sbrk()`; do not use `mmap()` for heap allocation. The test program measures memory consumption as the change in the program break.

Your `heapmgr` implementations should thoroughly validate function parameters by calling the standard `assert()` macro.

Your `heapmgr` implementations should check invariants by:
* Defining a thorough `check_heap_validity()` function, and
* Calling `assert(check_heap_validity())` at the leading and trailing edges of the `heapmgr_malloc()` and `heapmgr_free()` functions.

**Do not rename `check_heap_validity()`.** We will look for this function by name when grading.


Your `heapmgr` should implement the strategies for good memory utilization:
* heapmgr_malloc() should check blocks from the free list before allocating new memory
* If free block is bigger than requested, heapmgr_malloc() should divide the free block and keep leftover block in the free list
* heapmgr_free() should check lower/upper neighbor and coalesce if possible

If you ignore memory utilization, you won't get points no matter how fast your implementation is.

## Logistics

### Given codes

#### Makefile
* `Makefile` : makefile that can build executable files. Assuming that you have all the appropriate files, `Makefile` makes five executable files(`testheapmgrgnu`, `testheapmgrkr`, `testheapmgrbase`, `testheapmgr1` and `testheapmgr2`).

#### /reference
* `heapmgr.h`, `heapmgrgnu.c`, `heapmgrkr.c`, and `heapmgrbase.c`: as described above.
* `chunkbase.h` and `chunkbase.c`: a Chunk module used by `heapmgrbase.c`.

#### /src
* `chunk.h` and `chunk.c`: a Chunk module that you may use in both implementations of your `heapmgr` module.
* You may modify `chunk.h` and `chunk.c` and use them, or leave them as is and not use them.

#### /test
* `testheapmgr.c`: a client program that tests the `heapmgr` module, and reports timing and memory usage statistics.
* `testheap1`, `testheap2` and `testheapimp`: bash shell scripts that automate testing.  
The `testheap1` script assumes the existence of four executable files named `testheapmgrgnu`, `testheapmgrkr`, `testheapmgrbase`, `testheapmgr1`.  
The `testheap2` script assumes the existence of five executable files named `testheapmgrgnu`, `testheapmgrkr`, `testheapmgrbase`, `testheapmgr1` and `testheapmgr2`.

Note that `testheap1`, `testheap2` and `testheapimp` are used as executables, so you need to enable the file execution bit like `$ chmod +x testheap1` before using them.

### Perform a test

The `testheapmgr` program requires three command-line arguments. The first should be any one of seven strings, as shown in the following table, indicating which of seven tests the program should run:

| Argument | Test Performed |
|:---          |:---  |
| `LIFO_fixed` | LIFO with fixed size chunks |
| `FIFO_fixed` | FIFO with fixed size chunks |
| `LIFO_random` | LIFO with random size chunks |
| `FIFO_random` | FIFO with random size chunks |
| `random_fixed` | Random order with fixed size chunks |
| `random_random` | Random order with random size chunks |
| `worst` | Allocation order designed to stress first-fit search in a single, unbinned free list |

The second command-line argument is the number of calls of `heapmgr_malloc()` and `heapmgr_free()` that the program should execute. The third command-line argument is the (maximum) size, in bytes, of each memory chunk that the program should allocate and free.

Immediately before termination testheapmgr prints to stdout an indication of how much CPU time and heap memory it consumed. See the `testheapmgr.c` file for more details.

When testing, set the product of the number of calls (second command line argument) and size in bytes (third command line argument) to less than or equal to $5\times10^8$. In all tests evaluating the implementation on the Bacchus machine, the product of the number of calls (second command line argument) and size in bytes (third command line argument) is guaranteed to be less than or equal to $5\times10^8$.

### Make testheapmgr

You must build all test programs using the provided `Makefile` in the assignment root directory, since it records your compilation history in `history/`. Do not invoke `gcc800` directly. Only builds performed through the public Makefile targets create the required records in the `history` directory.

Use the `test1`, `test2`, or `testall` targets for debugging builds. These use `-O0 -g` to disable optimization and include symbols for GDB. Use the targets beginning with `time` for performance measurement. The performance targets use `-O3` (uppercase "oh", followed by the number "3") to enable optimization and `-D NDEBUG` to disable `assert` calls in the heap manager implementations and the time-consuming memory-content checks in `testheapmgr.c`.
The default `make` target builds the reference implementations and the required `heapmgr1.c` implementation. Use `make time2all` to include the optional `heapmgr2.c` implementation.

| `make` +  | commands to be executed |
|:---          |:---  |
| `test1` | `gcc800 -std=gnu99 -O0 -g test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` |
| `test2` | `gcc800 -std=gnu99 -O0 -g test/testheapmgr.c src/heapmgr2.c src/chunk.c -o test/testheapmgr2` |
| `testall` | `gcc800 -std=gnu99 -O0 -g test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` <br> `gcc800 -std=gnu99 -O0 -g test/testheapmgr.c src/heapmgr2.c src/chunk.c -o test/testheapmgr2` |
| `timegnu` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrgnu.c -o test/testheapmgrgnu` |
| `timekr` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrkr.c -o test/testheapmgrkr` |
| `timebase` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrbase.c reference/chunkbase.c -o test/testheapmgrbase` |
| `time1` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` |
| `time2` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr2.c src/chunk.c -o test/testheapmgr2` |
| `time1all` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrgnu.c -o test/testheapmgrgnu` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrkr.c -o test/testheapmgrkr` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrbase.c reference/chunkbase.c -o test/testheapmgrbase` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` |
| `time2all` | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrgnu.c -o test/testheapmgrgnu` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrkr.c -o test/testheapmgrkr` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrbase.c reference/chunkbase.c -o test/testheapmgrbase` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr2.c src/chunk.c -o test/testheapmgr2` |
| `all` <br> (same as time1all) | `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrgnu.c -o test/testheapmgrgnu` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrkr.c -o test/testheapmgrkr` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c reference/heapmgrbase.c reference/chunkbase.c -o test/testheapmgrbase` <br> `gcc800 -O3 -D NDEBUG -std=gnu99 test/testheapmgr.c src/heapmgr1.c src/chunk.c -o test/testheapmgr1` |
| `clean` | `rm -f test/testheapmgrgnu test/testheapmgrkr test/testheapmgrbase test/testheapmgr1 test/testheapmgr2` |

You can create additional test programs as you deem necessary. You need not submit your additional test programs.

### Make readme

Create a `readme` text file that contains:

* Your name and student ID.
* The **CPU times and heap memory consumed** by testheapmgr using `heapmgrgnu.c`, `heapmgrkr.c`, `heapmgrbase.c`, `heapmgr1.c`, and `heapmgr2.c`(optional), with all arguments(`LIFO_fixed`, `FIFO_fixed`, `LIFO_random`, `FIFO_random`, `random_fixed`, `random_random`, `worst`), with call count 50000, and with maximum chunk sizes 1000 and 10000.  
Note that if the CPU time consumed is more than **5 minutes**, `testheapmgr` will **abort execution**.  
To report the time and memory consumption, it is sufficient to paste the output of the `testheap1` or `testheap2` script into your `readme` file.
* (Optionally) An indication of how much time you spent doing the assignment.
* (Optionally) Your assessment of the assignment.
* (Optionally) Any information that will help us to grade your work in the most favorable light. In particular you should describe all known bugs.

### Submission

Compress the submission files into tar format using the following command (assuming your ID is 202600000):

If you want to submit only `heapmgr1.c`:
```
mkdir 202600000_assign3
mv src/heapmgr1.c src/chunk.c src/chunk.h readme history 202600000_assign3
tar zcf 202600000_assign3.tar.gz 202600000_assign3
```
If you want to submit both `heapmgr1.c` and `heapmgr2.c`:
```
mkdir 202600000_assign3
mv src/heapmgr1.c src/heapmgr2.c src/chunk.c src/chunk.h readme history 202600000_assign3
tar zcf 202600000_assign3.tar.gz 202600000_assign3
```
Upload your submission file (202600000_assign3.tar.gz) to eTL. We do not accept e-mail submission (unless our course eTL is down).

## Grading

We will grade your work on three aspects: submit format, quality from the user's point of view, and quality from the programmer's point of view.

| Category | Points |
|---|---|
| Submit format | 12 / 100 |
| User's point of view (function correctness) | 78 / 100 |
| Programmer's point of view | 10 / 100 |

### Submit format (12 / 100)

Your submission must include a `readme` and all required files with proper file names and extensions.
See the submission section for the exact directory structure and naming rules.

### User's point of view: function correctness (78 / 100)

From the user's point of view, your module has quality if it behaves as it should. We will check the following:

- **`check_heap_validity()` implementation**: It should check all possible error cases of your heap data structures.
- **Correctness**: Your code should execute all `malloc()` and `free()` calls without any memory errors.
- **Time consumption**: `heapmgr1` should be faster than `heapmgrkr` and `heapmgrbase`.
  - `free()` should be faster in 3 cases: `LIFO_fixed`, `LIFO_random`, `FIFO_random`
  - Total time should be faster in 2 cases: `random_fixed`, `random_random`
- **Memory utilization**: Memory usage should be comparable to `heapmgrkr` and `heapmgrbase`.
  - If your implementation uses more than 3× the memory of `heapmgrbase`, you will get no points for time consumption.

### Programmer's point of view (10 / 100)

From the programmer's point of view, your module has quality if it is well styled and thereby simple to maintain.
See the specifications of previous assignments for guidelines concerning style.

- **Clarity**: names, comments, line lengths, indentation, etc.
- **Parameter validation**: validate function parameters using `assert()`.
- Function modularity will be a prominent part of your grade.

### Extra credit: heapmgr2.c (+30%)

If you submit `heapmgr2.c`, you can get up to 30% of the score you received for implementing `heapmgr1.c` as extra credit. `heapmgr2` will be evaluated on the following:

- **`check_heap_validity()` implementation**: It should check all possible error cases.
- **Design**: `heapmgr_malloc()` and `heapmgr_free()` should be well-designed using bins.
- **Time consumption**: Total time should be faster than `heapmgrkr`, `heapmgrbase`, and `heapmgr1` in all 7 cases.
- **Memory utilization**: Same criteria as `heapmgr1`. Using more than 3× the memory of `heapmgrbase` results in no points for time consumption.

You will not get the 30% extra credit just by submitting `heapmgr2.c`. If you do not get a perfect score on `heapmgr2`, the extra credit you receive will be reduced.

Since extra credit is proportional to the score you received for implementing `heapmgr1.c`, we recommend that you first fully implement `heapmgr1.c` and then challenge the implementation of `heapmgr2.c`.

---

## Frequently Asked Questions (FAQ)

- **About the implementation of the code**

**Question 1.**  
`chunk.c`, `chunk.h` files are almost empty; Is there an error in the provided files?

**Answer.**  
These files are provided as almost empty files so that you can use `Makefile`.  
If you use `heapmgrbase.c` as a baseline, you can modify `chunkbase.c` and `chunkbase.h` and use them as chunk.c and chunk.h. In this case, you can remove given empty files.  
If not, you can leave `chunk.c` and `chunk.h` as empty files and use them just for the `Makefile`.  
Regardless of whether you modified `chunk.c` and `chunk.h`, you **must** submit `chunk.c` and `chunk.h`.  

**Question 2.**  
Is using `heapmgrbase.c`, `chunkbase.c` or `chunkbase.h` considered plagiarism?

**Answer.**  
No, using `heapmgrbase.c`, `chunkbase.c` and `chunkbase.h` as baselines of your implementation is **not** considered plagiarism.  
You can use the functions, structures, etc. from given `heapmgrbase.c`, `chunkbase.c` and `chunkbase.h`.

**Question 3.**  
When implementing bins, are there any limits on the number of bins, or the size of the chunks?

**Answer.**  
No, there are no limits outside of the specified input range ($5\times10^8$).

- **About the execution of the code**

**Question 4.**  
What is the environment for grading?

**Answer.**  
Your code will be graded on the Bacchus server.  
The code you submit will be placed in the `/src` folder, and the structure is completely identical to the structure of the assignment3 folder provided to you.  
In other words, the code you submit should **not** use any header files other than the code you wrote (e.g. do not use heapmgr.h in your implementation).  

**Question 5.**  
When performing tests in a local environment, the execution time often exceeds 5 minutes and stops; Can I adjust the time limit?

**Answer.**  
You can adjust the time limit for testing in a local environment.  
You can adjust the time limit by changing `s_rlimit.rlim_cur` and `s_rlimit.rlim_max` in `/test/testheapmgr.c`. (Default is 300)  

**Question 6.**  
When `Count` or `Size` is large, my code is fast enough, but when `Count` or `Size` is small, my code is slower than the existing code or has a similar speed. Is my implementation still not enough?

**Answer.**  
When `Count` or `Size` is not large enough, it is difficult to make difference in speed due to difference in implementation, and errors depending on the environment can easily affect the speed.  
When grading your code, we will grade it with large enough `Count` and `Size`.  
If your code is fast enough when tested with `Count = 50000` and `Size = 10000`, you don't need to worry about the results with small `Count` or `Size`.  

- **About grading criteria**

**Question 7.**  
How is correctness evaluated?

**Answer.**  
We will review your implementation of `check_heap_validity()` to see whether it thoroughly checks all corner cases of your heap data structures.  
We will also build your code using the `make test*` targets (with `-O0 -g`, without `-O3 -D NDEBUG`) and verify that it executes all `malloc()` and `free()` calls in the tests without any errors.

**Question 8.**  
When should I perform validity checks?

**Answer.**  
As mentioned in the `Your task` section above, `assert(check_heap_validity())` must be called on the leading and trailing edges of `heapmgr_malloc()` and `heapmgr_free()` functions.  
Creating additional validity checks and functions for them in other areas is permitted, but is not included in the grading criteria.

- **About readme**

**Question 9.**  
Should I run the execution results attached to the readme file on my local environment or on the bacchus machine?

**Answer.**  
It doesn't matter which environment you run them on.  
However, if timeouts occur frequently when running on your local environment, please attach the results from running them on the bacchus machine.

**Question 10.**  
Should I include the output with timeout in the readme file?

**Answer.**  
If the timeout occurs only in one or two cases, you can attach that output to the readme file.  
If the timeout occurs too often to verify that the implementation is correct based on the output alone, please use the output from a bacchus machine.  
It is guaranteed that the timeouts on a bacchus machine will not be a problem.

- **Other questions**

**Question 11.**  
I cannot run the test properly on MacOS.

**Answer.**  
Please try using Linux(VM/wsl, etc.).
