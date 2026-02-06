implement Fanoutfilter;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;
include "sh.m";
include "filter.m";
	filter: Filter;
stdin, stdout, stderr: ref Sys->FD;

Testfilt: module
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
	sh = load Sh Sh->PATH;
	if (sh == nil) {
		sys->fprint(stderr, "cannot load sh: %r\n");
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

# I need to encapsulate the filter later. 
mainfn(in: ref Iobuf)
{
	incnt, outcnt: int;
	
	
	fds := array[64] of { * => array[2] of { *=> ref Sys->FD }};
	for(i := 0; i < len fds; i++){
		sys->pipe(fds[i]);
		genesize(fds[i]);
	}	
	
	rec := load Filter "./nlf.dis";
	if(rec == nil)
		raise "filt not found";
	rq := rec->start("");
Filt:
	for(;;) pick m := <-rq {
	Fill =>
		n := in.read(m.buf, len m.buf);
		m.reply <-= n;
		sys->print("read %d\n", n);
		if(n == -1){
			sys->fprint(stderr, "err");
			break;
		}
		incnt += n;
	Result =>
		n := len m.buf;
		sys->print("n %d\n", n);
		do {
			hv := hash(buf)%(len fds-1);
			n -= sys->write(fds[hv][0], m.buf, len m.buf);
		}while(n > 0);
		m.reply <-= 0;
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

# djb2
hash(s: array of byte): int
{
	hash := 5381;
	c: int;
	for(i := 0; i < len s; i++)
		hash = ((hash << 5) + hash) + c;
	if(hash < 0)
		return -hash;
	return hash;
}

genesize(fds: array of ref Sys->FD, cmd: string)
{
	sys->pctl(Sys->FORKFD, nil);
	sys->dup(fds[0], 0);
	sys->dup(fds[1], 1);
 

}

getsysFD(): ref Sys->FD
{
	bind -b '#C' / 
	sh->system("9cpu -h go.cs.bell-labs.com -c 'emu -r $home/inferno sh -c ''{svc/net}''');
	
	sys->mount("
}
popen(ctxt: ref Draw->Context, argv: list of string): ref Sys->FD
{
	fds := array[2] of ref Sys->FD;
	sys->pipe(fds);
	spawn runcmd(ctxt, argv, fds[0], sync);
	return fds[1];
}

runcmd(ctxt: ref Draw->Context, argv: list of string, stdin: ref Sys->FD, sync: chan of int)
{
	sys->pctl(Sys->FORKFD, nil);
	sys->dup(stdin.fd, 0);
	stdin = nil;
	sh := load Sh Sh->PATH;
	sh->run(ctxt, argv);
}


fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

