package getargs

import "core:runtime"
import "core:c"
import "core:c/libc"

getargs_t :: struct {
    _getargs : rawptr,
}

getargs_payload_t :: struct #raw_union {
    boolean: u8,
    str: [^]c.char,
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

@export getargs_construct :: proc "c" (self: ^getargs_t) {
    context = runtime.default_context()
    construct(cast(^Getargs)self._getargs)
}

@export getargs_add_arg :: proc "c" (
    self: ^getargs_t,
    short_name: cstring,
    long_name: cstring,
    option: getargs_optarg_option_t,
) {
    context = runtime.default_context()
    add_arg(cast(^Getargs)self._getargs,
	    string(short_name),
	    string(long_name),
	    c_to_odin_Optarg_Option(option))
}

@export getargs_read_args :: proc "c" (self: ^getargs_t, args: [^]cstring, args_len: c.size_t) {
    context = runtime.default_context()
    array := carray_to_odin_array(args, args_len)
    defer delete(array)
    read_args(cast(^Getargs)self._getargs, array[:])
}

@export getargs_get_flag :: proc "c" (self: ^getargs_t, arg_name: cstring) -> c.int {
    context = runtime.default_context()
    ok := get_flag(cast(^Getargs)self._getargs, string(arg_name))
    if ok {
	return 1
    } else {
	return 0
    }
}

@export getargs_get_payload :: proc "c" (self: ^getargs_t, arg_name: cstring, is_err: ^c.int, is_boolean: ^c.int) -> getargs_payload_t {
    context = runtime.default_context()
    arg, is_true := get_payload(cast(^Getargs)self._getargs, string(arg_name))
    if !is_true {
	is_err^ = 1
	return getargs_payload_t{
	    str = nil,
	}
    }
    ret, is_bool := arg.payload.(bool)
    if (is_bool) {
	is_boolean^ = 1
	return getargs_payload_t{
	    boolean = u8(ret),
	}
    }
    str_len : uint = len(arg.payload.(string))
    cstr := cast([^]c.char) libc.malloc(str_len + 1)
    for v,i in arg.payload.(string) {
	cstr[i] = u8(v)
    }
    cstr[str_len] = 0
    return getargs_payload_t{
	str = cstr,
    }
}

c_to_odin_Optarg_Option :: proc(opt: getargs_optarg_option_t) -> Optarg_Option {
    switch(opt) {
    case .GETARGS_OPTARG_OPTION_NONE:
	return .None
    case .GETARGS_OPTARG_OPTION_REQUIRED:
	return .Required
    case .GETARGS_OPTARG_OPTION_OPTIONAL:
	return .Optional
    case:
	return .None
    }
}

carray_to_odin_array :: proc(carray: [^]cstring, carray_len: c.size_t) -> [dynamic]string {
    array : [dynamic]string
    for i : c.size_t = 0; i < carray_len; i += 1 {
	append(&array, string(carray[i]))
    }
    return array
}
