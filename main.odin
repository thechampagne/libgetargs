package getargs

import "core:runtime"
import "core:c/libc"

getargs_t :: struct {
    _getargs : rawptr,
}

getargs_optarg_option_t :: enum(i32) {
	GETARGS_OPTARG_OPTION_NONE,
	GETARGS_OPTARG_OPTION_REQUIRED,
	GETARGS_OPTARG_OPTION_OPTIONAL,
}

@export getargs_init :: proc "c" () -> getargs_t {
    context = runtime.default_context()
    new_getargs : ^Getargs = cast(^Getargs)libc.malloc(size_of(Getargs))
    init := make_getargs()
    new_getargs.arg_map = init.arg_map
    new_getargs.arg_vec = init.arg_vec
    new_getargs.arg_opts = init.arg_opts
    new_getargs.arg_idx = init.arg_idx
    return getargs_t {
	_getargs = cast(rawptr)new_getargs,
    }
}
