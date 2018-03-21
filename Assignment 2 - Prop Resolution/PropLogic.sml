structure PropLogic : sig
	           val compile : string -> DataType.Prop
                 end = 
struct

structure PropLogicLrVals =
  PropLogicLrValsFun(structure Token = LrParser.Token)

structure PropLogicLex =
  PropLogicLexFun(structure Tokens = PropLogicLrVals.Tokens)

structure PropLogicParser =
  JoinWithArg(structure LrParser = LrParser
   structure ParserData = PropLogicLrVals.ParserData
   structure Lex = PropLogicLex)

exception PropError;

fun compile (fileName) =
	let val inStream =  TextIO.openIn fileName;
		val grab : int -> string = fn
			n => if TextIO.endOfStream inStream
				then ""
				else TextIO.inputN (inStream, n);
		val printError : string * int * int -> unit = fn
			(msg, line, col) =>
			print (fileName ^ "[" ^ Int.toString line ^ ":"
				^ Int.toString col ^ "] " ^ msg ^ "\n");
		val (tree, rem) = PropLogicParser.parse
						(15,
						(PropLogicParser.makeLexer grab fileName),
						printError,
						fileName)
			handle PropLogicParser.ParseError => raise PropError;
		val _ = TextIO.closeIn inStream;
	in tree
	end
end;
