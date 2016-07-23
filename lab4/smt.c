
/*Ahmed Ezzat Mohamed Hefny Elmeleh 377483, Chidozie Benjamin Ezepue 376612, Tijmen Lodewijk Verhulsdonck 376822*/
#include <unistd.h>
#include <pthread.h>
#include <sched.h>
#include <sys/syscall.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <immintrin.h>

//define the number here with the core assigned to you
#define CPUID_SMT0 23
#define CPUID_SMT1 (CPUID_SMT0+24)

//enable and disable your SMT thread
#define SMT1_ON 1

static int fibonacci(int n){
  if(n==0){
    return 0;
  }
  else{
    if(n==1)
      return 1;
    else
      return (fibonacci(n-1)+fibonacci(n-2));
  }
}

static void *tf_smt0(void *targ){
  cpu_set_t mask;
  CPU_ZERO(&mask);
  CPU_SET(CPUID_SMT0, &mask);
  pid_t tid = syscall(SYS_gettid); //glibc does not provide a wrapper for gettid
  sched_setaffinity(tid, sizeof(cpu_set_t), &mask);

  printf("Fibonacci number 40 = %d\n", fibonacci(40));

  pthread_exit(NULL);
}

static void *tf_smt1(void *targ){
  cpu_set_t mask;
  CPU_ZERO(&mask);
  CPU_SET(CPUID_SMT1, &mask);
  pid_t tid = syscall(SYS_gettid); //glibc does not provide a wrapper for gettid
  sched_setaffinity(tid, sizeof(cpu_set_t), &mask);

      double num[3] = {28823037615171174, 717152730140019477,
                     288230376151711743};
    __m128d value;
    double *aligned_memory = (double *)((long long)(&num[1]) & (-1<<4));
    value = _mm_load_pd(aligned_memory);
    while (1)
    {
//An empty while loop is just a sequence of constant jumps that interfere and disturb the fibonacci
//thread from carrying out its jcc, call and return statements. We decided that adding some code that performs some complex operations
// to the while loop should slow down the frequency of the constant jumps and give more freedom to the fibonacci thread to execute its own
// jcc, call and return
//
//
//We decided to use dependent instructions because in an ideal situation they will be waiting for one functional to finish it's work i.e waiting for 
//each other's result. And at the same time leaving all other functional units free. In this case a parallel thread can fully utilize these free
//functional units(assuming this parallel thread is also not waiting for the same functional unit to be free)
//
//
//Mfence serializes loads and stores. It stops all successor instructions from executing until the preceding instructions and mfence are doe executing
//This delays the while loop a little. Mfence produces better results than other serializing instructions like CPUID and Lfence.
       value = _mm_sqrt_pd(value);
       value = _mm_mul_pd(value,value);
       value = _mm_sqrt_pd(value);
       value = _mm_mul_pd(value,value);
       value = _mm_sqrt_pd(value);
       value = _mm_mul_pd(value,value);
       value = _mm_sqrt_pd(value);
       value = _mm_mul_pd(value,value);
       value = _mm_sqrt_pd(value);
       value = _mm_mul_pd(value,value);
       _mm_store_pd(aligned_memory,value);
       _mm_mfence();
 // put your "background" code here
    // no sleeps are other code that schedules the thread out is allowed
    // inline assembly is not allowed
    }
  
  //To be sure that the previous loop is not optimized away by the compiler
  printf("This should not appear\n");
  pthread_exit(NULL);
}

static int64_t diff(struct timespec start, struct timespec end)
{
  struct timespec temp;
  int64_t d;
  if ((end.tv_nsec-start.tv_nsec)<0) {
      temp.tv_sec = end.tv_sec-start.tv_sec-1;
      temp.tv_nsec = 1000000000+end.tv_nsec-start.tv_nsec;
  } else {
      temp.tv_sec = end.tv_sec-start.tv_sec;
      temp.tv_nsec = end.tv_nsec-start.tv_nsec;
  }
  d = temp.tv_sec*1000000000+temp.tv_nsec;
  return d;
}

int main ()
{
  pthread_t smt0, smt1;
  struct timespec start, end;

  clock_gettime(CLOCK_REALTIME,&start);

  pthread_create(&smt0, NULL, tf_smt0, NULL);
#if SMT1_ON
  pthread_create(&smt1, NULL, tf_smt1, NULL);
#endif

  pthread_join(smt0, NULL);
  clock_gettime(CLOCK_REALTIME,&end);
#if SMT1_ON
  pthread_cancel(smt1);
#endif

  double time = (double) diff(start,end)/1000000;
  printf("\nExecution time thread SMT0 \t %.3f ms\n", time);

  return 0;
}
