implement Textmux;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;
include "../mux.m";
	mux: Mux;

stdin, stdout, stderr: ref Sys->FD;

Textmux: module
{
	init: fn(nil: ref Draw->Context, argv: list of string);
};

usage()
{
	fail("usage", sys->sprint("usage: testmux.b [-ud] [file]"));
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
				fail("open file", sys->sprint("testmux.b: cannot open %s: %r\n", hd argv));
			mainfn(in);
		}
	}else{
		in := bufio->fopen(stdin, Bufio->OREAD);
		mainfn(in);
	}

}

mainfn(in: ref Iobuf)
{
	incnt, outcnt: int;
	rec := load Mux "./blm.dis";
	if(rec == nil)
		raise "filt not found";
	rq := rec->start("", 2, 2);
Filt:
	for(;;) pick m := <-rq {
	Fill =>
		n := in.read(m.buf, len m.buf);
		m.reply <-= (0, n);
		s := sys->sprint("read %d\n", n);
		out.puts(s);
		if(n == -1){
			sys->fprint(stderr, "err");
			break;
		}
		incnt += n;
	Result =>
		n := len m.buf;
		s := sys->sprint("len %d n %d\n", n, m.n);
		out.puts(s);
		s = sys->sprint("m.n %d buf %s\n", m.n, string m.buf);
		out.puts(s);
		m.reply <-= (m.n, 0);
		outcnt += n;
	Info =>
		sys->fprint(stderr, "%s\n", m.msg);
	Finished =>
		break Filt;
	Error =>
		sys->fprint(stderr, "error comp\n");
		break;
	}	
	out.flush();
}

fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

