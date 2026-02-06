implement TestRec;

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
	arg: Arg;
include "lock.m";
	lock: Lock;
	Semaphore: import lock;

stdin, stdout, stderr: ref Sys->FD;

TestRec: module
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
	lock = load Lock Lock->PATH;
	if (lock == nil) {
		sys->fprint(stderr, "cannot load lock: %r\n");
		raise "fail:init";
	}
	lock->init();		
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
NWRITE: con 4;
BUFSZ: con 128*1024;
wlock : ref Semaphore;
mainfn(in: ref Iobuf)
{
	p := array[2] of ref Sys->FD;
	if(sys->pipe(p) == -1)
		return;
	buf := array[BUFSZ] of byte;
	bs := buf;
	recbuf : array of byte; 
	n := 0;
	wlock = Semaphore.new();
	for(i := 0; i < NWRITE; i++)
		spawn writer(p[1]);
	for(;;){
		nread := 0;
		for (;nread < len buf;) {
			toread := len buf - nread;
			n := sys->read(p[0], buf[nread:], toread);
			sys->write(sys->fildes(1), buf, len buf);
		#	sys->print("nread %d\n", nread);
			if (n <= 0)
				break;
			nread += n;
		}
	}
}

i := 0;
writer(fd: ref Sys->FD)
{
	sent := "writer "+string i+++" 0123456789abcde\n"; #bytes
	buf := array[BUFSZ] of byte;
	for(i := 0; i < len buf-3; i++)
		buf[i] = byte sent[i%len sent];
	buf[i++] = byte '\n';
	buf[i++] = byte '';
	buf[i] = byte '\n';
	for(;;){
		wlock.obtain();
		nwritten := 0;
		for (;nwritten < len buf;) {
			towrite := len buf - nwritten;
			n := sys->write(fd, buf[nwritten:], towrite);
			if (n <= 0)
				break;
			nwritten += n;
		#	sys->print("nwritten %d\n", nwritten);
		}
		wlock.release();
	}

}

fail(ex, msg: string)
{
	sys->fprint(sys->fildes(2), "%s\n", msg);
	raise "fail:"+ex;
}

