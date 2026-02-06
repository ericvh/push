implement Filter;

include "sys.m";
include "filter.m";

init()
{
}

start(param: string): chan of ref Rq
{
	req := chan of ref Rq;
	spawn getnl(req);
	return req;
	
}
getnl(reqs: chan of ref Rq)
{
	sys := load Sys Sys->PATH;
	reqs <-= ref Rq.Start(sys->pctl(0, nil));
	buf := array[8192] of { * => byte 0};
	rest := array[0] of byte;
	rc := chan of int;
	do{
		reqs <-= ref Rq.Fill(buf, rc);
		if((n := <-rc) <= 0){
			if(n == 0)
				reqs <-= ref Rq.Finished(nil);
			break;
		}
		for(i := len buf-1; i != 0 && i-1 != 0; i--)
			if(buf[i] == byte '\n' && buf[i-1] == byte '\n')
				break;
		obuf := array[len rest + i] of byte;
		obuf[0:] = rest;
		obuf[len rest:] = buf[0:i];
		# this is not good. think of a better way. 
		reqs <-= ref Rq.Result(obuf, rc);
		rest = buf[i:len buf];
	}while(<-rc != -1);
}
