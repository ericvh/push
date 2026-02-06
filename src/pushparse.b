implement Pushparse;

#line	2	"push.y"
include	"push.m";

#
#	push parser.  Thread safe.
#
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

#line	28	"push.y"
	lib:		Pushlib;

	Cmd, Item, Stab, Env:		import lib;
YYEOFCODE: con 1;
YYERRCODE: con 2;
YYMAXDEPTH: con 200;

#line	248	"push.y"


init(l: Pushlib)
{
	lib = l;
}

parse(e: ref Env)
{
	y := ref YYENV;
	y.yyenv = e;
	y.yysys = lib->sys;
	y.yystderr = e.stderr;
	yyeparse(y);
}

yyerror(e: ref YYENV, s: string)
{
	e.yyenv.report(s);
	e.yyenv.suck();
}

yyelex(e: ref YYENV): int
{
	return e.yyenv.lex(e.yylval);
}
yyexca := array[] of {-1, 1,
	1, -1,
	-2, 0,
-1, 2,
	1, 1,
	-2, 0,
-1, 21,
	26, 53,
	27, 53,
	-2, 50,
};
YYNPROD: con 77;
YYPRIVATE: con 57344;
yytoknames: array of string;
yystates: array of string;
yydebug: con 0;
YYLAST:	con 280;
yyact := array[] of {
   7,  20,   4,  51,  43,  49, 114,  69, 107,  99,
 116, 150,  34, 146,  35, 144,  17, 133, 132, 131,
  61,  62,  40,  41,  30,  66,  67,  68,  65,  42,
 130,  22,  48,  40,  37,  38,  36,  39,  71,  73,
  74,  75,  22,  40, 115,  80,  78,  79,  47,  46,
  81,  72,  22,  84,  85,  26,  24,  25,  92,  93,
  94,  95,  96,  82, 128, 102, 103,  97,  98,  72,
  40,  34, 101,  35,  70, 110,  77, 111,  70,  22,
  76, 112, 113,  45,  83,  64,  29,  28,  27, 147,
  60,  59, 108, 120, 121, 122, 123, 124, 109,  34,
  34,  35,  35,  40,  41, 126, 136,  38, 135,  39,
  42, 127,  22,  64, 129,  58,   3,  57, 139, 140,
   2,  64, 137,   1, 138, 143,   6,  64,  16,  13,
  14,  15,   8, 145, 100,  63, 134,  71,  73, 106,
  34, 105,  35,  88,  87,   9,  21,  33, 151, 152,
  32,  44, 153, 119,  11,  22, 142,  12,  16,  13,
  14,  15,  18,  10,  19,  31,   5,  23,   0,  89,
  91,  90,  88,  87,   0,   0,  21,  56,  53,  54,
  55,  50,  41,   0,  11,  22,  86,  12,  42,   0,
  52, 141,  18,  58,  19,  57,  56,  53,  54,  55,
  50,  41,   0, 148,  26,  24,  25,  42,   0,  52,
   0,   0,  58,   0,  57,  40,  41, 108,   0,  40,
  41,   0,  42, 109,  22,   0,  42,  58,  22,  57,
   0,  58,   0,  57,  89,  91,  90,  88,  87, 125,
  26,  24,  25,   0,  89,  91,  90,  88,  87, 149,
 118,   0,   0,   0,   0,  89,  91,  90,  88,  87,
 117,   0,   0,   0,   0,  89,  91,  90,  88,  87,
 104,   0,   0,   0,   0,  89,  91,  90,  88,  87,
};
yypact := array[] of {
-1000,-1000, 124,-1000,-1000,-1000,-1000,  45,-1000,-1000,
   0,-1000,  53,  18,  17,   1, 178,  64,  11,  11,
 110,-1000, 178,-1000, 154, 154, 154,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,  96,-1000,  48,  21,  11,  11,
-1000,  50,  46,  14, 154,-1000,  62, 178, 178, 156,
-1000,-1000, 178, 178, 178, 178, 178,  44,  39,-1000,
-1000, 104, 104,  11,  11, 262,-1000,-1000,-1000, 193,
-1000,  96,-1000,  96,  96,  96,-1000,-1000,-1000,-1000,
  45,  12, -29,-1000, 252, 242,-1000, 178, 178, 178,
 178, 178, 231,-1000,-1000,-1000,-1000, 197, 197,-1000,
-1000,-1000,  68,-1000,-1000,-1000,-1000,-1000,  34,-1000,
  -2, -13, -14, -15,  72,-1000,-1000, 154, 154, 159,
-1000, 127, 127, 127, 127,-1000, -17,-1000,-1000, -19,
-1000,-1000,-1000,-1000,-1000,  11,  11,  72,  81, 194,
 230,-1000,-1000, 221,-1000, -21,-1000, 154, 154, 154,
-1000, 230, 230,-1000,
};
yypgo := array[] of {
   0, 167, 165,   3, 139,   1, 136,  16, 163,   7,
 156, 153,   0,   2,   4, 151, 145,   6,   5,   8,
 141,   9, 132, 123, 120, 116,
};
yyr1 := array[] of {
   0,  23,  24,  24,  25,  25,  25,  15,  15,  13,
  14,  14,  12,  12,  12,  12,  12,  22,  22,  16,
  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,
  16,  19,  19,  20,  20,  21,  21,  11,  11,  10,
   8,   8,   2,   2,   4,   4,   3,   3,   3,   3,
   5,   5,   5,   7,   9,   9,  17,  17,   6,   6,
   6,   6,   1,   1,   1,  18,  18,  18,  18,  18,
  18,  18,  18,  18,  18,  18,  18,
};
yyr2 := array[] of {
   0,   1,   0,   2,   1,   1,   1,   0,   2,   2,
   1,   2,   1,   1,   3,   3,   3,   1,   4,   4,
   5,   7,   5,   7,   5,   5,   3,   3,   3,   3,
   4,   4,   3,   0,   1,   0,   3,   0,   2,   3,
   1,   2,   1,   1,   1,   1,   4,   4,   4,   4,
   1,   3,   3,   1,   0,   2,   0,   2,   2,   2,
   2,   2,   1,   1,   1,   1,   1,   3,   3,   2,
   2,   2,   2,   3,   3,   3,   3,
};
yychk := array[] of {
-1000, -23, -24, -25, -13,  42,   2, -12, -22, -16,
  -8,  30,  33,   5,   6,   7,   4,  -7,  38,  40,
  -5,  22,  31,  -1,  11,  12,  10,  43,  42,  41,
  24,  -2,  -4,  -6,  -5,  -3,  36,  34,  35,  37,
  22,  23,  29, -14, -15,  30,  31,  31,  31, -18,
  22,  -3,  31,  19,  20,  21,  18,  36,  34,  27,
  26,  -5,  -5,  25,  17, -18, -12, -12, -12,  -9,
  30,  -5,  30,  -5,  -5,  -5,  30,  30,  32, -13,
 -12, -14,  -7,  22, -18, -18,  30,  17,  16,  13,
  15,  14, -18, -18, -18, -18, -18,  -9,  -9, -21,
  30, -21,  -5,  -5,   8, -20,  -4, -19,  24,  30,
 -14, -14, -14, -14, -17,  32,  39,   8,   8, -11,
 -18, -18, -18, -18, -18,   8, -14, -19,  30, -14,
  32,  32,  32,  32,  -6,  36,  34, -17,  -9, -12,
 -12,  32, -10, -18,  32, -14,  32,   8,   9,  28,
  32, -12, -12, -13,
};
yydef := array[] of {
   2,  -2,  -2,   3,   4,   5,   6,   0,  12,  13,
  17,   7,   0,   0,   0,   0,   0,   0,   0,   0,
  40,  -2,   0,   9,   0,   0,   0,  62,  63,  64,
  54,  41,  42,  43,  44,  45,   0,   0,   0,   0,
  50,   0,   0,   0,  10,   7,   0,   0,   0,   0,
  65,  66,   0,   0,   0,   0,   0,   0,   0,  54,
  54,  35,  35,   0,   0,   0,  14,  15,  16,  33,
   7,  58,   7,  59,  60,  61,   7,   7,  56,   8,
  11,   0,   0,  53,   0,   0,  37,   0,   0,   0,
   0,   0,   0,  69,  70,  71,  72,  26,  27,  28,
   7,  29,   0,  51,  52,  18,  55,  34,   0,   7,
   0,   0,   0,   0,  19,  56,  54,   0,   0,   0,
  68,  73,  74,  75,  76,  67,   0,  30,   7,   0,
  48,  49,  46,  47,  57,   0,   0,  20,   0,  22,
  24,  25,  38,   0,  36,   0,  32,   0,   0,   0,
  31,  21,  23,  39,
};
yytok1 := array[] of {
   1,
};
yytok2 := array[] of {
   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,
  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,
  42,  43,  44,
};
yytok3 := array[] of {
   0
};
YYFLAG: con -1000;

# parser for yacc output
YYENV: adt
{
	yylval:	ref YYSTYPE;	# lexical value
	yyval:	YYSTYPE;		# goto value
	yyenv:	YYETYPE;		# useer environment
	yynerrs:	int;			# number of errors
	yyerrflag:	int;			# error recovery flag
	yysys:	Sys;
	yystderr:	ref Sys->FD;
};

yytokname(yyc: int): string
{
	if(yyc > 0 && yyc <= len yytoknames && yytoknames[yyc-1] != nil)
		return yytoknames[yyc-1];
	return "<"+string yyc+">";
}

yystatname(yys: int): string
{
	if(yys >= 0 && yys < len yystates && yystates[yys] != nil)
		return yystates[yys];
	return "<"+string yys+">\n";
}

yylex1(e: ref YYENV): int
{
	c, yychar : int;
	yychar = yyelex(e);
	if(yychar <= 0)
		c = yytok1[0];
	else if(yychar < len yytok1)
		c = yytok1[yychar];
	else if(yychar >= YYPRIVATE && yychar < YYPRIVATE+len yytok2)
		c = yytok2[yychar-YYPRIVATE];
	else{
		n := len yytok3;
		c = 0;
		for(i := 0; i < n; i+=2) {
			if(yytok3[i+0] == yychar) {
				c = yytok3[i+1];
				break;
			}
		}
		if(c == 0)
			c = yytok2[1];	# unknown char
	}
	if(yydebug >= 3)
		e.yysys->fprint(e.yystderr, "lex %.4ux %s\n", yychar, yytokname(c));
	return c;
}

YYS: adt
{
	yyv: YYSTYPE;
	yys: int;
};

yyparse(): int
{
	return yyeparse(nil);
}

yyeparse(e: ref YYENV): int
{
	if(e == nil)
		e = ref YYENV;
	if(e.yylval == nil)
		e.yylval = ref YYSTYPE;
	if(e.yysys == nil) {
		e.yysys = load Sys "$Sys";
		e.yystderr = e.yysys->fildes(2);
	}

	yys := array[YYMAXDEPTH] of YYS;

	yystate := 0;
	yychar := -1;
	e.yynerrs = 0;
	e.yyerrflag = 0;
	yyp := -1;
	yyn := 0;

yystack:
	for(;;){
		# put a state and value onto the stack
		if(yydebug >= 4)
			e.yysys->fprint(e.yystderr, "char %s in %s", yytokname(yychar), yystatname(yystate));

		yyp++;
		if(yyp >= YYMAXDEPTH) {
			yyerror(e, "yacc stack overflow");
			yyn = 1;
			break yystack;
		}
		yys[yyp].yys = yystate;
		yys[yyp].yyv = e.yyval;

		for(;;){
			yyn = yypact[yystate];
			if(yyn > YYFLAG) {	# simple state
				if(yychar < 0)
					yychar = yylex1(e);
				yyn += yychar;
				if(yyn >= 0 && yyn < YYLAST) {
					yyn = yyact[yyn];
					if(yychk[yyn] == yychar) { # valid shift
						yychar = -1;
						yyp++;
						if(yyp >= YYMAXDEPTH) {
							yyerror(e, "yacc stack overflow");
							yyn = 1;
							break yystack;
						}
						yystate = yyn;
						yys[yyp].yys = yystate;
						yys[yyp].yyv = *e.yylval;
						if(e.yyerrflag > 0)
							e.yyerrflag--;
						if(yydebug >= 4)
							e.yysys->fprint(e.yystderr, "char %s in %s", yytokname(yychar), yystatname(yystate));
						continue;
					}
				}
			}
		
			# default state action
			yyn = yydef[yystate];
			if(yyn == -2) {
				if(yychar < 0)
					yychar = yylex1(e);
		
				# look through exception table
				for(yyxi:=0;; yyxi+=2)
					if(yyexca[yyxi] == -1 && yyexca[yyxi+1] == yystate)
						break;
				for(yyxi += 2;; yyxi += 2) {
					yyn = yyexca[yyxi];
					if(yyn < 0 || yyn == yychar)
						break;
				}
				yyn = yyexca[yyxi+1];
				if(yyn < 0){
					yyn = 0;
					break yystack;
				}
			}

			if(yyn != 0)
				break;

			# error ... attempt to resume parsing
			if(e.yyerrflag == 0) { # brand new error
				yyerror(e, "syntax error");
				e.yynerrs++;
				if(yydebug >= 1) {
					e.yysys->fprint(e.yystderr, "%s", yystatname(yystate));
					e.yysys->fprint(e.yystderr, "saw %s\n", yytokname(yychar));
				}
			}

			if(e.yyerrflag != 3) { # incompletely recovered error ... try again
				e.yyerrflag = 3;
	
				# find a state where "error" is a legal shift action
				while(yyp >= 0) {
					yyn = yypact[yys[yyp].yys] + YYERRCODE;
					if(yyn >= 0 && yyn < YYLAST) {
						yystate = yyact[yyn];  # simulate a shift of "error"
						if(yychk[yystate] == YYERRCODE) {
							yychar = -1;
							continue yystack;
						}
					}
	
					# the current yyp has no shift on "error", pop stack
					if(yydebug >= 2)
						e.yysys->fprint(e.yystderr, "error recovery pops state %d, uncovers %d\n",
							yys[yyp].yys, yys[yyp-1].yys );
					yyp--;
				}
				# there is no state on the stack with an error shift ... abort
				yyn = 1;
				break yystack;
			}

			# no shift yet; clobber input char
			if(yydebug >= 2)
				e.yysys->fprint(e.yystderr, "error recovery discards %s\n", yytokname(yychar));
			if(yychar == YYEOFCODE) {
				yyn = 1;
				break yystack;
			}
			yychar = -1;
			# try again in the same state
		}
	
		# reduction by production yyn
		if(yydebug >= 2)
			e.yysys->fprint(e.yystderr, "reduce %d in:\n\t%s", yyn, yystatname(yystate));
	
		yypt := yyp;
		yyp -= yyr2[yyn];
#		yyval = yys[yyp+1].yyv;
		yym := yyn;
	
		# consult goto table to find next state
		yyn = yyr1[yyn];
		yyg := yypgo[yyn];
		yyj := yyg + yys[yyp].yys + 1;
	
		if(yyj >= YYLAST || yychk[yystate=yyact[yyj]] != -yyn)
			yystate = yyact[yyg];
		case yym {
			
4=>
#line	63	"push.y"
{ yys[yypt-0].yyv.cmd.xeq(e.yyenv); }
7=>
#line	69	"push.y"
{ e.yyval.cmd = nil; }
8=>
#line	71	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cseq, yys[yypt-1].yyv.cmd, yys[yypt-0].yyv.cmd); }
9=>
#line	75	"push.y"
{ e.yyval.cmd = yys[yypt-1].yyv.cmd.mkcmd(e.yyenv, yys[yypt-0].yyv.flag); }
10=>
e.yyval.cmd = yys[yyp+1].yyv.cmd;
11=>
#line	80	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cseq, yys[yypt-1].yyv.cmd, yys[yypt-0].yyv.cmd.mkcmd(e.yyenv, 0)); }
12=>
e.yyval.cmd = yys[yyp+1].yyv.cmd;
13=>
e.yyval.cmd = yys[yyp+1].yyv.cmd;
14=>
#line	86	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cfanin, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
15=>
#line	88	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cfanout, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
16=>
#line	90	"push.y"
{  e.yyval.cmd = Cmd.cmd2(Cpipe, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
17=>
#line	94	"push.y"
{ e.yyval.cmd = e.yyenv.mksimple(yys[yypt-0].yyv.items); }
18=>
#line	96	"push.y"
{
				yys[yypt-0].yyv.cmd.words = e.yyenv.mklist(yys[yypt-1].yyv.items);
				e.yyval.cmd = Cmd.cmd1w(Cdepend, yys[yypt-0].yyv.cmd, e.yyenv.mklist(yys[yypt-3].yyv.items));
			}
19=>
#line	103	"push.y"
{ e.yyval.cmd = yys[yypt-0].yyv.cmd.cmde(Cgroup, yys[yypt-2].yyv.cmd, nil); }
20=>
#line	105	"push.y"
{ e.yyval.cmd = yys[yypt-0].yyv.cmd.cmde(Csubgroup, yys[yypt-2].yyv.cmd, nil); }
21=>
#line	107	"push.y"
{ e.yyval.cmd = Cmd.cmd1i(Cfor, yys[yypt-0].yyv.cmd, yys[yypt-4].yyv.item); e.yyval.cmd.words = lib->revitems(yys[yypt-2].yyv.items); }
22=>
#line	109	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cif, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
23=>
#line	111	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cif, yys[yypt-4].yyv.cmd, Cmd.cmd2(Celse, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd)); }
24=>
#line	113	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cwhile, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
25=>
#line	115	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Ccase, yys[yypt-3].yyv.cmd, yys[yypt-1].yyv.cmd.rotcases()); }
26=>
#line	117	"push.y"
{ e.yyval.cmd = Cmd.cmdiw(Ceq, yys[yypt-2].yyv.item, yys[yypt-0].yyv.items); }
27=>
#line	119	"push.y"
{ e.yyval.cmd = Cmd.cmdiw(Cdefeq, yys[yypt-2].yyv.item, yys[yypt-0].yyv.items); }
28=>
#line	121	"push.y"
{ e.yyval.cmd = Cmd.cmd1i(Cfn, yys[yypt-0].yyv.cmd, yys[yypt-1].yyv.item); }
29=>
#line	123	"push.y"
{ e.yyval.cmd = Cmd.cmd1i(Crescue, yys[yypt-0].yyv.cmd, yys[yypt-1].yyv.item); }
30=>
#line	125	"push.y"
{
				yys[yypt-0].yyv.cmd.item = yys[yypt-1].yyv.item;
				e.yyval.cmd = Cmd.cmd1i(Crule, yys[yypt-0].yyv.cmd, yys[yypt-3].yyv.item);
			}
31=>
#line	132	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Clistgroup, yys[yypt-1].yyv.cmd); }
32=>
#line	134	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Cgroup, yys[yypt-1].yyv.cmd); }
33=>
#line	138	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Cnop, nil); }
34=>
e.yyval.cmd = yys[yyp+1].yyv.cmd;
35=>
#line	143	"push.y"
{ e.yyval.cmd = nil; }
36=>
#line	145	"push.y"
{ e.yyval.cmd = yys[yypt-1].yyv.cmd; }
37=>
#line	149	"push.y"
{ e.yyval.cmd = nil; }
38=>
#line	151	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Ccases, yys[yypt-1].yyv.cmd, yys[yypt-0].yyv.cmd); }
39=>
#line	155	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cmatched, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
40=>
#line	159	"push.y"
{ e.yyval.items = yys[yypt-0].yyv.item :: nil; }
41=>
#line	161	"push.y"
{ e.yyval.items = yys[yypt-0].yyv.item :: yys[yypt-1].yyv.items; }
42=>
e.yyval.item = yys[yyp+1].yyv.item;
43=>
e.yyval.item = yys[yyp+1].yyv.item;
44=>
e.yyval.item = yys[yyp+1].yyv.item;
45=>
e.yyval.item = yys[yyp+1].yyv.item;
46=>
#line	173	"push.y"
{ e.yyval.item = Item.itemc(Ibackq, yys[yypt-1].yyv.cmd); }
47=>
#line	175	"push.y"
{ e.yyval.item = Item.itemc(Iquote, yys[yypt-1].yyv.cmd); }
48=>
#line	177	"push.y"
{ e.yyval.item = Item.itemc(Iinpipe, yys[yypt-1].yyv.cmd); }
49=>
#line	179	"push.y"
{ e.yyval.item = Item.itemc(Ioutpipe, yys[yypt-1].yyv.cmd); }
50=>
e.yyval.item = yys[yyp+1].yyv.item;
51=>
#line	184	"push.y"
{ e.yyval.item = Item.item2(Icaret, yys[yypt-2].yyv.item, yys[yypt-0].yyv.item); }
52=>
#line	186	"push.y"
{ e.yyval.item = Item.itemc(Iexpr, yys[yypt-1].yyv.cmd); }
53=>
#line	190	"push.y"
{ e.yyval.item = yys[yypt-0].yyv.item.sword(e.yyenv); }
54=>
#line	194	"push.y"
{ e.yyval.items = nil; }
55=>
#line	196	"push.y"
{ e.yyval.items = yys[yypt-0].yyv.item :: yys[yypt-1].yyv.items; }
56=>
#line	200	"push.y"
{ e.yyval.cmd = ref Cmd; e.yyval.cmd.error = 0; }
57=>
#line	202	"push.y"
{ e.yyval.cmd = yys[yypt-1].yyv.cmd; yys[yypt-1].yyv.cmd.cmdio(e.yyenv, yys[yypt-0].yyv.item); }
58=>
#line	206	"push.y"
{ e.yyval.item = Item.itemr(Rin, yys[yypt-0].yyv.item); }
59=>
#line	208	"push.y"
{ e.yyval.item = Item.itemr(Rout, yys[yypt-0].yyv.item); }
60=>
#line	210	"push.y"
{ e.yyval.item = Item.itemr(Rappend, yys[yypt-0].yyv.item); }
61=>
#line	212	"push.y"
{ e.yyval.item = Item.itemr(Rinout, yys[yypt-0].yyv.item); }
62=>
#line	216	"push.y"
{ e.yyval.flag = 0; }
63=>
#line	218	"push.y"
{ e.yyval.flag = 0; }
64=>
#line	220	"push.y"
{ e.yyval.flag = 1; }
65=>
#line	224	"push.y"
{ e.yyval.cmd = Cmd.cmd1i(Cword, nil, yys[yypt-0].yyv.item); }
66=>
#line	226	"push.y"
{ e.yyval.cmd = Cmd.cmd1i(Cword, nil, yys[yypt-0].yyv.item); }
67=>
#line	228	"push.y"
{ e.yyval.cmd = yys[yypt-1].yyv.cmd; }
68=>
#line	230	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Ccaret, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
69=>
#line	232	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Chd, yys[yypt-0].yyv.cmd); }
70=>
#line	234	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Ctl, yys[yypt-0].yyv.cmd); }
71=>
#line	236	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Clen, yys[yypt-0].yyv.cmd); }
72=>
#line	238	"push.y"
{ e.yyval.cmd = Cmd.cmd1(Cnot, yys[yypt-0].yyv.cmd); }
73=>
#line	240	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Ccons, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
74=>
#line	242	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Ceqeq, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
75=>
#line	244	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cnoteq, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
76=>
#line	246	"push.y"
{ e.yyval.cmd = Cmd.cmd2(Cmatch, yys[yypt-2].yyv.cmd, yys[yypt-0].yyv.cmd); }
		}
	}

	return yyn;
}
