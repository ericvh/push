Mux: module
{
	SLIPPATH: con "/dis/lib/slip.dis";

	Rq: adt {
		pick {
		Start =>
			pid: int;
		Fill =>
			buf: array of byte;
			reply: chan of (int, int);
		Result =>
			buf: array of byte;
			n: int;
			reply: chan of (int, int);			
		Info =>
			msg: string;
		Finished =>
			buf: array of byte;
		Error =>
			e: string;
		}
	};

	init: fn();
	# 
	start: fn(param: string, nin, nout: int): chan of ref Rq;
};

# so for a mux you want to give it a value.
# and then you want 
# the result. a demux. tells it which to write to. 
# you can write a multiplexer or demultiplexer this way. 
# only when you have a full value do you do that. 
# it keeps track. 
