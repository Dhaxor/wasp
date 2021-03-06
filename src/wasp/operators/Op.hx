package wasp.operators;

import haxe.io.BytesBuffer;
import haxe.io.BytesOutput;
import wasp.types.ValueType;
import wasp.types.BlockType;
import wasp.Global.*;

class Op {
	// The single-byte opcode
	public var code:Int;

	// The name of the operator
	public var name:String;

	public static var NativeExec = Op.init(0xfe, "nativeExec", [ValueTypeI64], cast BlockTypeEmpty);

	public static var internalOpcodes:Map<Int, Bool> = [NativeExec => true];

	/**
	 * Whether this operator is polymorphic.
	 * A polymorphic operator has a variable arity. call, call_indirect, and
	 * drop are examples of polymorphic operators.
	 */
	public var polymorphic:Bool;

	public var args:Array<ValueType>;

	public var returns:ValueType;

	public function new() {
		args = [];
	}

	public static function New(code:Int) {
		var buf = new BytesBuffer();
		buf.addByte(code);

		if (code >= ops.length || internalOpcodes[code]) {
			throw 'Invalid opcode: 0x${buf.getBytes().toHex()}';
		}

		var op = ops[code];
		if (!(op.name != "") && ops.get(code) != null) {
			throw 'Invalid opcode: 0x${buf.getBytes().toHex()}';
		}

		op.args = [];

		return op;
	}

	// public static inline function newOp(code:Int):Int {
	// 	if (ops[code].isValid()) {
	// 		var buf = new BytesOutput();
	// 		buf.writeByte(code);
	// 		throw 'Opcode 0x${buf.getBytes().toHex()} is already assigned to ${ops[code].name}';
	// 	}
	// 	var op = new Op(code);
	// 	// op.code = code;
	// 	op.name = name;
	// 	op.args = args;
	// 	op.returns = returns;
	// 	op.polymorphic = false;
	// 	ops[code] = op;
	// 	return code;
	// }

	public static function init(code:Int, name:String, args:Array<ValueType>, returns:ValueType) {
		if (name != "" && ops.get(code) != null) {
			// var buf = new BytesOutput();
			// buf.writeByte(code);
			// throw 'Opcode 0x${buf.getBytes().toHex()} is already assigned to ${ops[code].name}';
		} else {
			var op = new Op();
			op.code = code;
			op.name = name;
			op.args = args;
			op.returns = returns;

			op.polymorphic = false;

			ops[code] = op;
		}

		return code;
	}

	public static function initPolymorphic(code:Int, name:String):Int {
		if (name != "" && ops.get(code) != null) {
			// var buf = new BytesOutput();
			// buf.writeByte(code);
			// throw 'Opcode 0x${buf.getBytes().toHex()} is already assigned to ${ops[code].name}';
		} else {
			var op = new Op();
			op.code = code;
			op.name = name;

			op.polymorphic = true;

			ops[code] = op;
		}

		return code;
	}

	public static function initConversion(code:Int, name:String):Int {
		var r = ~/(.+)\.(?:[a-z]|_)+\/(.+)/g;
		if (r.match(name)) {
			var returns = valType(r.matched(1));
			var param = valType(r.matched(2));
			return init(code, name, [param], returns);
		}

		return 0;
	}

	public function isValid():Bool {
		return this.name != "";
	}

	static function valType(s:String):ValueType {
		return switch s {
			case "i32":
				ValueTypeI32;
			case "i64":
				ValueTypeI64;
			case "f32":
				ValueTypeF32;
			case "f64":
				ValueTypeF64;
			default:
				throw 'Invalid value type string: $s';
		}
	}
}
