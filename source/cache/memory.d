module cache.memory;

import cache;

import std.stdio;
import core.memory;

class BufferTrunk
{
	string key;
	ulong length;
	ubyte[] *ptr;
	BufferTrunk prv;
	BufferTrunk next;
	this(string key,ubyte[] value,ulong length)
	{
		this.key = key;
		this.length = length;
		ptr = cast(ubyte[] *)GC.malloc(length);
		*ptr = value;
	}
	void clean()
	{
		length = 0;
		GC.free(ptr);
	}
	~this()
	{
		if(length)GC.free(ptr);
	}
}

class Memory : Store
{
	private ulong trunkNum;
	private ulong trunkSize;
	private BufferTrunk[string] map;
	private BufferTrunk head;
	private BufferTrunk tail;

	this()
	{
	}
	
	~this()
	{
	}
	ulong getTrunkNum()
	{
		return trunkNum;
	}
	ulong getTrunkSize()
	{
		return trunkSize;
	}
	override bool set(string key,ubyte[] value)
	{
		if(isset(key))return false;
		BufferTrunk trunk = new BufferTrunk(key,value,value.length);
		map[key] = trunk;
		trunkNum++;
		trunkSize+=value.length;
		if(head is BufferTrunk.init){
			head = trunk;
			tail = trunk;
		}else{
			tail.next = trunk;
			trunk.prv = tail;
			tail = trunk;
		}
		return true;
	}
	override ubyte[]  get(string key)
	{
		return map.get(key,null) ? *(map[key].ptr) : null;
	}
	override bool isset(string key)
	{
		if(map.get(key,null) is null) 
			return false;
		return true;
	}
	override bool remove(string key)
	{
		if(!isset(key))return true;
		if(map[key].prv)map[key].prv.next = map[key].next;
		if(map[key].next)map[key].next.prv = map[key].prv;
		trunkNum--;
		trunkSize-=map[key].length;
		map[key].clean();
		map[key].destroy();
		map.remove(key);
		return true;
	}
	override void clean()
	{
		foreach(k,v;map){
			v.clean();
			v.destroy();
			map.remove(k);
		}
		map.destroy();
		trunkNum = 0;
		trunkSize = 0;
		head = null;
		tail = null;
	}
}

unittest
{
	import std.stdio;
	Memory memory = new Memory();
	string test = "test";
	ubyte[] utest = cast(ubyte[])test;
	memory.set(test,utest);
	assert(memory.getTrunkNum == 1);
	assert(memory.getTrunkSize == utest.length);
	assert(memory.get(test) == utest);
	string test2 = "testasdfasjdflkjaklsdjfl";
	ubyte[] utest2 = cast(ubyte[])test2;
	memory.set(test2,utest2);
	assert(memory.getTrunkNum == 2);
	assert(memory.getTrunkSize == utest.length + utest2.length);
	assert(memory.get(test2) == utest2);
	assert(memory.get("testsdfadf") == null);
	memory.remove(test2);
	assert(memory.getTrunkNum == 1);
	assert(memory.getTrunkSize == utest.length);
	memory.clean();
	assert(memory.getTrunkNum == 0);
}
