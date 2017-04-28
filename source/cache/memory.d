module cache.memory;

import cache;

import std.experimental.allocator.gc_allocator;

class BufferTrunk
{
	string key;
	ulong length;
	void[] ptr;
	BufferTrunk* next;
	this(string key,ubyte[] value,ulong length)
	{
		this.key = key;
		this.length = length;
		ptr = GCAllocator.instance.allocate(length);
		ptr = value;
	}
	void destroy()
	{
		length = 0;
		GCAllocator.instance.deallocate(ptr);
	}
	~this()
	{
		if(length)GCAllocator.instance.deallocate(ptr);
	}
}

class Memory
{
	ulong trunkNum;
	ulong trunkSize;
	BufferTrunk*[string] map;
	BufferTrunk* head;
	BufferTrunk* tail;

	this()
	{
	
	}
	
	~this()
	{
	
	}
	bool check(string key)
	{
		foreach(k,v;map){
			if(key == k)return true;
		}
		return false;
	}
	bool set(string key,ubyte[] value)
	{
		if(check(key))return false;
		BufferTrunk trunk = new BufferTrunk(key,value,value.length);
		map[key] = &trunk;
		trunkNum++;
		trunkSize+=value.length;
		if(head == null){
			head = &trunk;
			tail = &trunk;
		}else{
			tail.next = &trunk;
			tail = &trunk;
		}
		return true;
	}
	ubyte[] get(string key)
	{
		return null;
	}
	bool isset(string key)
	{
		return false;
	}
	bool remove(string key)
	{
		return false;
	}
	void clean()
	{
	
	}
}

unittest
{
	Memory memory = new Memory();
	string test = "test";
	ubyte[] utest = cast(ubyte[])test;
	memory.set("test",utest);
	assert(memory.trunkNum == 1);
	assert(memory.trunkSize == utest.length);
	string test2 = "testasdfasjdflkjaklsdjfl";
	ubyte[] utest2 = cast(ubyte[])test2;
	memory.set("test2",utest2);
	assert(memory.trunkNum == 2);
	assert(memory.trunkSize == utest.length + utest2.length);
}
