#
#	Manage the execution of a command.
#

srv:	string;		# srv file proto
nsrv:	int = 0;	# srv file unique id

#
#	Return error string.
#
errstr(): string
{
	return sys->sprint("%r");
}

#
#	Server thread for servefd.
#
server(c: ref Sys->FileIO, fd: ref Sys->FD, write: int)
{
	a: array of byte;
	if (!write)
		a = array[Sys->ATOMICIO] of byte;
	for (;;) {
		alt {
		(nil, b, nil, wc) := <- c.write =>
			if (wc == nil)
				return;
			if (!write) {
				wc <- = (0, EPIPE);
				return;
			}
			r := sys->write(fd, b, len b);
			if (r < 0) {
				wc <- = (0, errstr());
				return;
			}
			wc <- = (r, nil);
		(nil, n, nil, rc) := <- c.read =>
			if (rc == nil)
				return;
			if (write) {
				rc <- = (array[0] of byte, nil);
				return;
			}
			if (n > Sys->ATOMICIO)
				n = Sys->ATOMICIO;
			r := sys->read(fd, a, n);
			if (r < 0) {
				rc <- = (nil, errstr());
				return;
			}
			rc <- = (a[0:r], nil);
		}
	}
}

#
#	Serve FD as a #s file.  Used to implement generators.
#
Env.servefd(e: self ref Env, fd: ref Sys->FD, write: int): string
{
	(s, c) := e.servefile(nil);
	spawn server(c, fd, write);
	return s;
}

#
#	Generate name and FileIO adt for a served filed.
#
Env.servefile(e: self ref Env, n: string): (string, ref Sys->FileIO)
{
	c: ref Sys->FileIO;
	s: string;
	if (srv == nil) {
		(ok, d) := sys->stat(CHAN);
		if (ok < 0)
			e.couldnot("stat", CHAN);
		if (d.dtype != 's') {
			if (sys->bind("#s", CHAN, Sys->MBEFORE) < 0)
				e.couldnot("bind", CHAN);
		}
		srv = "push." + string sys->pctl(0, nil);
	}
	retry := 0;
	for (;;) {
		if (retry || n == nil)
			s = srv + "." + string nsrv++;
		else
			s = n;
		c = sys->file2chan(CHAN, s);
		s = CHAN + "/" + s;
		if (c == nil) {
			if (retry || n == nil || errstr() != EEXISTS)
				e.couldnot("file2chan", s);
			retry = 1;
			continue;
		}
		break;
	}
	if (n != nil)
		n = CHAN + "/" + n;
	else
		n = s;
	if (retry && sys->bind(s, n, Sys->MREPL) < 0)
		e.couldnot("bind", n);
	return (n, c);
}

#
#	Shorthand for string output.
#
Env.output(e: self ref Env, s: string)
{
	if (s == nil)
		return;
	out := e.outfile();
	if (out == nil)
		return;
	out.puts(s);
	out.close();
}

#
#	Return Iobuf for stdout.
#
Env.outfile(e: self ref Env): ref Bufio->Iobuf
{
	fd := e.out;
	if (fd == nil)
		fd = sys->fildes(1);
	out := bufio->fopen(fd, Bufio->OWRITE);
	if (out == nil)
		e.report(sys->sprint("fopen failed: %r"));
	return out;
}

#
#	Return FD for /dev/null.
#
Env.devnull(e: self ref Env): ref Sys->FD
{
	fd := sys->open(DEVNULL, Sys->OREAD);
	if (fd == nil)
		e.couldnot("open", DEVNULL);
	return fd;
}


#
#	Make a pipe.
#
Env.pipe(e: self ref Env): array of ref Sys->FD
{
	fds := array[2] of ref Sys->FD;
	if (sys->pipe(fds) < 0) {
		e.report(sys->sprint("pipe failed: %r"));
		return nil;
	}
	return fds;
}
#
#	Multipipe
#
Env.multipipe(e: self ref Env, n: int): array of array of ref Sys->FD
{
	fds := array[n] of { * => array[2] of { * =>  ref Sys->FD}};
	for(i := 0; i < len fds; i++)
		if (sys->pipe(fds[i]) < 0) {
			e.report(sys->sprint("pipe failed: %r"));
			return nil;
		}
	return fds;
}
#
#	Open wait file for an env.
#
waitfd(e: ref Env)
{
	w := "#p/" + string sys->pctl(0, nil) + "/wait";
	fd := sys->open(w, sys->OREAD);
	if (fd == nil)
		e.couldnot("open", w);
	e.wait = fd;
}

#
#	Wait for a thread.  Perhaps propagate exception or exit.
#
waitfor(e: ref Env, pid: int, wc: chan of int, ec, xc: chan of string)
{
	if (ec != nil || xc != nil) {
		spawn waiter(e, pid, wc);
		if (ec == nil)
			ec = chan of string;
		if (xc == nil)
			xc = chan of string;
		alt {
		<-wc =>
			return;
		<-ec => # x := 
			<-wc;
			exitpush();
		x := <-xc =>
			<-wc;
			s := x;
			if (len s < FAILLEN || s[0:FAILLEN] != FAIL)
				s = FAIL + s;
			raise s;
		}
	} else
		waiter(e, pid, nil);
}

#
#	Wait for a specific pid.
#
waiter(e: ref Env, pid: int, wc: chan of int)
{
	buf := array[sys->WAITLEN] of byte;
	for(;;) {
		n := sys->read(e.wait, buf, len buf);
		if (n < 0) {
			e.report(sys->sprint("read wait: %r\n"));
			break;
		}
		status := string buf[0:n];
		if (status[len status - 1] != ':')
			sys->fprint(e.stderr, "%s\n", status);
		who := int status;
		if (who != 0 && who == pid)
			break;
	}
	if (wc != nil)
		wc <-= 0;
}

#
#	Preparse IO for a new thread.
#	Make a new FD group and redirect stdin/stdout.
#
prepareio(in, out: ref sys->FD): (int, ref Sys->FD)
{
	fds := list of { 0, 1, 2};
	if (in != nil)
		fds = in.fd :: fds;
	if (out != nil)
		fds = out.fd :: fds;
	pid := sys->pctl(sys->NEWFD, fds);
	console := sys->fildes(2);
	if (in != nil) {
		sys->dup(in.fd, 0);
		in = nil;
	}
	if (out != nil) {
		sys->dup(out.fd, 1);
		out = nil;
	}
	return (pid, console);
}

include "mux.m";

# can I make this more general?

		# this may be a really bad idea, what happens if you don't accept 0?
		# so how are we going to deal with blocking reads?
		# the system is doing a blocking read and stopping.
		
reader(infd: ref Sys->FD, rc: chan of array of byte)
{

	buf := array[8192] of byte;
	if(rc == nil || infd == nil || buf == nil){
		sys->fprint(sys->fildes(2), "rc/infd/buf is nil\n");
		raise "fail: rc/infd/buf is nil";
	}
	for(;;){
		sys->print("reader infd %bx\n", sys->fstat(infd).t1.qid.path);
		n := sys->read(infd, buf, len buf);
		sys->print("reader %d %s\n", n, string buf[:n]);
		if(n <= 0)
			break;
		rc <-= buf[:n];
	}
}

faninproc(infd: array of array of ref Sys->FD, outfd: ref Sys->FD, e: ref Env)
{
	rc := array[len infd] of { * => chan of array of byte };
	for(i := 0; i < len infd; i++)
		spawn reader(infd[i][1], rc[i]);
	sym := e.dollar("ORS");
	if(sym == nil)
		e.report("ORS not defined"); 
	rec := load Mux hd sym.value;
	if(rec == nil)
		e.report("ORS filter not found");
	rq := rec->start("", len infd, 0);
Mux:
	for(;;) pick m := <-rq {
	Fill =>
		# how will this exit?
		(j, a) := <-rc;
		m.buf[0:] = a; # the copy is wrong here. I need to change the filter into a mux.
		m.reply <-= (j, len a);
		if(a == nil){
			sys->fprint(sys->fildes(2), "err");
			break;
		}
	Result =>
		n := len m.buf;
		do {
			sys->print("fanin write n %d outfd %bx\n", n, sys->fstat(outfd).t1.qid.path);
			n -= sys->write(outfd, m.buf, len m.buf);
		}while(n > 0);
		m.reply <-= (0, 0);
	Info =>
		sys->fprint(sys->fildes(2), "%s\n", m.msg);
	Finished =>
		break Mux;
	Error =>
		sys->fprint(sys->fildes(2), "fanin error: %s\n", m.e);
		break;
	}
}
# this should probably just have an environment.
fanoutproc(infd: ref Sys->FD, outfd: array of array of ref Sys->FD, e: ref Env)
{
	incnt, outcnt: int;
	sym := e.dollar("ORS");
	if(sym == nil)
		raise "fail:ORS not defined"; 
	rec := load Mux hd sym.value;
	if(rec == nil){
		sys->fprint(sys->fildes(2), "ORS filter not found\n");
		raise "fail:raise filter";
	}
	rq := rec->start("", 0, len outfd);
Mux:
	for(;;) pick m := <-rq {
	Fill =>
		n := sys->read(infd, m.buf, len m.buf);
		sys->print("fanout read n %d infd %bx\n", n, sys->fstat(infd).t1.qid.path);
		m.reply <-= (0, n);
		if(n == -1){
			sys->fprint(sys->fildes(2), "err");
			break;
		}
		incnt += n;
	Result =>
		n := len m.buf;
		do{
			sys->print("fanout write n %d outfd[%d][0] %bx\n", n, m.n, sys->fstat(e.mp[m.n][0]).t1.qid.path);
			n -= sys->write(outfd[m.n][0], m.buf, n);
		}while(n > 0);
		m.reply <-= (0, n);
		outcnt += n;
	Info =>
		sys->fprint(sys->fildes(2), "%s\n", m.msg);
	Finished =>
	#	for(i := 0; i < len outfd; i++)
	#		outfd[i][0] = nil;
		break Mux;
	Error =>
		sys->fprint(sys->fildes(2), "fanout error: %s\n", m.e);
		break;
	}
}
# djb2
djhash(s: array of byte): int
{
	h := 5381;
	for(i := 0; i < len s; i++)
		h = ((h << 5) + h) + int s[i];
	if(h < 0)
		return -h;
	return h;
}
genesize(fds: array of ref Sys->FD, cmd: string)
{
	fds = fds;
	cmd = cmd;
#	sys->pctl(Sys->FORKFD, nil);
#	sys->dup(fds[0], 0);
#	sys->dup(fds[1], 1);
}
#
#	Add ".dis" to a command if missing.
#
dis(s: string): string
{
	if (len s < 4 || s[len s - 4:] != ".dis")
		return s + ".dis";
	return s;
}

#
#	Load a builtin.
#
Env.doload(e: self ref Env, s: string)
{
	file := dis(s);
	l := load Pushbuiltin file;
	if (l == nil) {
		err := errstr();
		if (nonexistent(err) && file[0] != '/' && file[0:2] != "./") {
			l = load Pushbuiltin LIB + file;
			if (l == nil)
				err = errstr();
		}
		if (l == nil) {
			e.report(s + ": " + err);
			return;
		}
	}
	l->pushinit("load" :: s :: nil, lib, l, e);
}

#
#	Execute a spawned thread (dis module or builtin).
#
mkprog(args: list of string, e: ref Env, in, out: ref Sys->FD, wc: chan of int, ec, xc: chan of string)
{
	(pid, console) := prepareio(in, out);
	wc <-= pid;
	if (pid < 0)
		return;
	cmd := hd args;
	{
		b := e.builtin(cmd);
		if (b != nil) {
			e = e.copy();
			e.in = in;
			e.out = out;
			e.stderr = console;
			e.wait = nil;
			b->pushcmd(e, args);
		} else {
			file := dis(cmd);
			c := load Command file;
			if (c == nil) {
				err := errstr();
				if (nonexistent(err) && file[0] != '/' && file[0:2] != "./") {
					c = load Command "/dis/" + file;
					if (c == nil)
						err = errstr();
				}
				if (c == nil) {
					sys->fprint(console, "%s: %s\n", file, err);
					return;
				}
			}
			c->init(gctxt, args);
		}
	}exception x{
	FAILPAT =>
		if (xc != nil)
			xc <-= x;
		# the command failure should be propagated silently to
		# a higher level, where $status can be set.. - wrtp.
		#else
		#	sys->fprint(console, "%s: %s\n", cmd, x.name);
		exit;
	EPIPE =>
		if (xc != nil)
			xc <-= x;
		#else
		#	sys->fprint(console, "%s: %s\n", cmd, x.name);
		exit;
	EXIT =>
		if (ec != nil)
			ec <-= x;
		exit;
	}
}

#
#	Open/create files for redirection.
#
redirect(e: ref Env, f: array of string, in, out: ref Sys->FD): (int, ref Sys->FD, ref Sys->FD)
{
	s: string;
	err := 0;
	if(e.flags & EPdebug)
		sys->print("in %bx out %bx\n", sys->fstat(in).t1.qid.path, sys->fstat(out).t1.qid.path);
	if (f[Rinout] != nil) {
		s = f[Rinout];
		in = sys->open(s, Sys->ORDWR);
		if (in == nil) {
			sys->fprint(e.stderr, "%s: %r\n", s);
			err = 1;
		}
		out = in;
	} else if (f[Rin] != nil) {
		s = f[Rin];
		in = sys->open(s, Sys->OREAD);
		if (in == nil) {
			sys->fprint(e.stderr, "%s: %r\n", s);
			err = 1;
		}
	}
	if (f[Rout] != nil || f[Rappend] != nil) {
		if (f[Rappend] != nil) {
			s = f[Rappend];
			out = sys->open(s, Sys->OWRITE);
			if (out != nil)
				sys->seek(out, big 0, Sys->SEEKEND);
		} else {
			s = f[Rout];
			out = nil;
		}
		if (out == nil) {
			out = sys->create(s, Sys->OWRITE, 8r666);
			if (out == nil) {
				sys->fprint(e.stderr, "%s: %r\n", s);
				err = 1;
			}
		}
	}
	if (err)
		return (0, nil, nil);
	return (1, in, out);
}

#
#	Spawn a command and maybe wait for it.
#
exec(a: list of string, e: ref Env, infd, outfd: ref Sys->FD, wait: int)
{
	if (wait && e.wait == nil)
		waitfd(e);
	wc := chan of int;
	if (wait && (e.flags & ERaise))
		xc := chan of string;
	if (wait && (e.flags & ETop))
		ec := chan of string;
	spawn mkprog(a, e, infd, outfd, wc, ec, xc);
	pid := <-wc;
	if (wait)
		waitfor(e, pid, wc, ec, xc);
}
