implement Testreg;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;
include "registries.m";
	registries: Registries;
	Registry, Attributes, Service: import registries;
	
stdin, stdout, stderr: ref Sys->FD;

Testreg: module
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
	registries = load Registries Registries->PATH;
	if(registries == nil)
		fail("fail", "couldn't load "+Registries->PATH);
	registries->init();
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
	addreg();
	
	out.flush();
}

addreg()
{
	reg := Registry.new("/mnt/registry");
	if(reg == nil)
		reg = Registry.connect(nil, nil, nil);
	if(reg == nil)
		fail("fail", "void: cannot register: %r\n");
	# look up sysname push. 
	# should be "resource=push host="+getenv());
	(nil, host) := getenv("sysname");
	if(host == nil)
		host = "localhost";
	(svc, s) := reg.find(("rsrc","push")::("host",host)::nil);
	# I get that. 
	# get a higher port number. 
	maxport := 7873;
	for(l := svc; l != nil; l = tl l){
		(n, a) := sys->tokenize((hd l).addr, "!");
		if(n != 3)
			fail("bad addr", "invalid address");
		port := int hd tl tl a;
		if(port > maxport)
			maxport = port;
	}
	maxport++;
	# should be "net!"+host+"!"+string maxport+" rsrc=push host="+host
	(regd, s1) := reg.register("net!"+host+"!"+string maxport, ref Attributes(("rsrc","push")::("host",host)::nil),1);
	return regd;
}

fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

getenv(name: string): (int, string)
{
	fd := sys->open("#e/"+name, Sys->OREAD);
	if(fd == nil)
		return (0, nil);
	b := array[256] of byte;
	n := sys->read(fd, b, len b);
	if(n <= 0)
		return (1, "");
	for(i := 0; i < n; i++)
		if(b[i] == byte 0 || b[i] == byte '\n')
			break;
	return (1, string b[0:i]);
}

