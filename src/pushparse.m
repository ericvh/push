Pushparse: module {

	PATH:	con "/dis/lib/pushparse.dis";

	init:		fn(l: Pushlib);
	parse:	fn(e: ref Pushlib->Env);

	YYSTYPE: adt
	{
		cmd:		ref Pushlib->Cmd;
		item:		ref Pushlib->Item;
		items:	list of ref Pushlib->Item;
		flag:		int;
	};

	YYETYPE:	type ref Pushlib->Env;
Lcase: con	57346;
Lfor: con	57347;
Lif: con	57348;
Lwhile: con	57349;
Loffparen: con	57350;
Lelse: con	57351;
Lpipe: con	57352;
Lfanin: con	57353;
Lfanout: con	57354;
Leqeq: con	57355;
Lmatch: con	57356;
Lnoteq: con	57357;
Lcons: con	57358;
Lcaret: con	57359;
Lnot: con	57360;
Lhd: con	57361;
Ltl: con	57362;
Llen: con	57363;
Lword: con	57364;
Lbackq: con	57365;
Lcolon: con	57366;
Lcolonmatch: con	57367;
Ldefeq: con	57368;
Leq: con	57369;
Lmatched: con	57370;
Lquote: con	57371;
Loncurly: con	57372;
Lonparen: con	57373;
Loffcurly: con	57374;
Lat: con	57375;
Lgreat: con	57376;
Lgreatgreat: con	57377;
Lless: con	57378;
Llessgreat: con	57379;
Lfn: con	57380;
Lin: con	57381;
Lrescue: con	57382;
Land: con	57383;
Leof: con	57384;
Lsemi: con	57385;
Lerror: con	57386;
};
