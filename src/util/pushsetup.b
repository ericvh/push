implement Pushsetup;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;
include "sh.m";

stdin, stdout, stderr: ref Sys->FD;

Pushsetup: module
{
	init: fn(nil: ref Draw->Context, argv: list of string);
};

usage()
{
	fail("usage", sys->sprint("usage: uniq [-ud] [file]"));
}

rflag:=0;

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
			mainfn();
		}
	}else{
		mainfn();
	}

}

mainfn()
{
	if(sys->bind("#|", "/n/push", Sys->MAFTER) == -1)
		raise "fail: couldn't bind";
#	sys->listen("push");
	out := sys->open("/n/push/data", Sys->OWRITE);
	if(out == nil)
		raise "fail: couldn't open pipe";
	sys->dup(out.fd, 1);
	for(i := 0; i < 10; i++)
		spawn mkprog();
	pout := sys->open("/n/push/data1", Sys->OREAD);
	buf := array[8192] of byte;
	while((n := sys->read(pout, buf, len buf)) > 0)
		sys->write(stdout, buf, n);
#	cmd := load Command "/dis/cat.dis";
#	cmd->init(nil,"cat"::"/lib/ndb/local"::nil);	
}
mkprog()
{
	cmd := load Command "/dis/cat.dis";
	cmd->init(nil,"cat"::"/lib/ndb/local"::nil);
}

fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

genesize(): ref Sys->FD
{

}

void()
{
	# create a new inferno instance
	# read the registry for inferno's available on that instance. 
	# post that inferno's port 
	
}

# TODO
# get a registry working
# post the inferno's to the registry
