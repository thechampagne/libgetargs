#ifndef __GETARGS_H__
#define __GETARGS_H__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  void* _getargs;
} getargs_t;

typedef union {
  uint8_t boolean;
  char* str;
} getargs_payload_t;

typedef enum {
    GETARGS_OPTARG_OPTION_NONE,
    GETARGS_OPTARG_OPTION_REQUIRED,
    GETARGS_OPTARG_OPTION_OPTIONAL,
} getargs_optarg_option_t;

extern getargs_t getargs_init(void);

extern void getargs_construct(getargs_t* self);

extern void getargs_add_arg(getargs_t* self, const char* short_name, const char* long_name, getargs_optarg_option_t option);

extern void getargs_read_args(getargs_t* self, const char** args, size_t args_len);

extern int getargs_get_flag(getargs_t* self, const char* arg_name);

extern getargs_payload_t getargs_get_payload(getargs_t* self, const char* arg_name, int* is_err, int* is_boolean);

extern void getargs_clean(getargs_t* self);

#ifdef __cplusplus
}
#endif

#endif // __GETARGS_H__
