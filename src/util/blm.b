implement Mux;

include "sys.m";
include "../mux.m";

init()
{
}

start(param: string, nin, nout: int): chan of ref Rq
{
	req := chan of ref Rq;
	param = param; # shut up the compiler.
	spawn getnl(req, nin, nout);
	return req;
}

getnl(reqs: chan of ref Rq,  nin, nout: int)
{
	sys := load Sys Sys->PATH;
	reqs <-= ref Rq.Start(sys->pctl(0, nil));
	ibufs := array[nin] of array of byte;
	buf := array[8192] of byte;
	rc := chan of (int, int);
rqloop:
	for(;;){
		reqs <-= ref Rq.Fill(buf, rc);
		(i, n) := <-rc;
		# add leftovers. 
		if(len ibufs > 0){
			if(i >= len ibufs){
				reqs <-= ref Rq.Error("invalid mux index: "+string i+" max "+ string len ibufs);
				break;
			}
			if((a := ibufs[i]) != nil){
				tmp: array of byte;
				if((len a + n) < len buf){
					tmp = buf;
				}else
					tmp =  array[len a+n] of byte;
				tmp[len a:]= buf[:n];
				tmp[0:] = a;
				buf = tmp;
				ibufs[i] = nil;				
			}
		}		
		if(n <= 0){
			if(n == 0)
				reqs <-= ref Rq.Finished(nil);
			break;
		}
		if(len ibufs != 0 && i >= len ibufs)
			reqs <-= ref Rq.Error("invalid input buffer");
		oldj := 0;	
		for(j := 0; j < n; j++)
			if(buf[j] == byte '\n'){
				out := buf[oldj:j+1];
				hv := 0;
				if(nout > 1) # don't hash unless we're fanning out.
					hv = djhash(out) % nout;
			#	sys->print("%d %s", hv, string out);
				reqs <-= ref Rq.Result(out, hv, rc);
				(nil, n0) := <-rc;
				if(n0 == -1)
					break rqloop;
				oldj = j+1;
			}
		if(j == oldj || len ibufs == 0) # buffer has no leftovers
			continue;
		rest := buf[j+1:];
		if(ibufs[i] == nil)
			ibufs[i] = rest;
		else{
			# inefficient.
			newbuf := array[len ibufs[i] + len rest] of byte;
			newbuf[0:] = ibufs[i];
			newbuf[len ibufs[i]:] = rest;
			ibufs[i] = newbuf;
		}

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