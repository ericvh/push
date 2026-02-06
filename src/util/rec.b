
getrec()
{
	fpath = symtab.find("IRS");
	rec := load Filter fpath;
	rq := rec->start(param)
	for(;;) pick m := <-rq {
	Fill =>
		n := read(fd, m.buf, len m.buf);
		m.reply <-= n;
		if(n == -1){
			sys->fprint(stderr, "err");
			return 0;
		}
		incnt += n;
	Result =>
		n := len m.buf;
		sys->write(fd, m.buf, n) != n;
		m.reply <-= 0;
		outcnt += n;
	Info =>
		sys->fprint(stderr, "%s\n", m.msg);
	Finished =>
		;
	Error =>
		sys->fprint(stderr, "%s: error compressing %s: %s\n");
		return 0;
	}
}