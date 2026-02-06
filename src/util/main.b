implement Pushmain;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;

stdin, stdout, stderr: ref Sys->FD;

Pushmain: module
{
	init: fn(nil: ref Draw->Context, argv: list of string);
};

usage()
{
	fail("usage", sys->sprint("usage: uniq [-ud] [file]"));
}

rflag:=0;
out: ref Iobuf;

init(nil : ref Draw->Context, argv : list of string)
{
	sys = load Sys Sys->PATH;
	stdin  = sys->fildes(0);
	stdout = sys->fildes(1);
	stderr = sys->fildes(2);

	bufio = load Bufio Bufio->PATH;
	if (bufio == nil) {
		sys->fprint(stderr, "cannot load bufio: %r\n");
		raise "fail:init";
	}
	arg = load Arg Arg->PATH;
	if (arg == nil) {
		sys->fprint(stderr, "cannot load arg: %r\n");
		raise "fail:init";
	}	
	out = bufio->fopen(stdout, Sys->OWRITE);
	arg->init(argv);
	while ((c := arg->opt()) != 0) case c {
	'r' => rflag = 1;
	* => raise sys->sprint("fail:unknown option (%c)\n", c);
	}
	argv = tl argv;
	if (len argv > 1)
		usage();
	if (argv != nil) {
		for(; argv != nil; argv=tl argv) {
			in := bufio->open(hd argv, Bufio->OREAD);
			if (in == nil)
				fail("open file", sys->sprint("uniq: cannot open %s: %r\n", hd argv));
			mainfn(in);
		}
	}else{
		in := bufio->fopen(stdin, Bufio->OREAD);
		mainfn(in);
	}

}

mainfn(in: ref Iobuf)
{
	getcmd();
	out := push->distcmd();
	while(
	out.puts("hello world!");
	out.flush();
}
getcmd()
{
	# usual parse, will not work that way in mash.
}

fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

