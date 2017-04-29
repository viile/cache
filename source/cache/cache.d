module cache.cache;

import cache;

class Cache
{
	Store _store;

	this(Store store)
	{
		this._store = store;
	}

	bool set(string key,ubyte[] value)
	{
		return _store.set(key,value);		
	}
	bool set(string key,string value)
	{
		return set(key,cast(ubyte[])value);
	}

	ubyte[] get(string key)
	{
		return _store.get(key);
	}

	bool remove(string key)
	{
		return _store.remove(key);
	}

	bool isset(string key)
	{
		return _store.isset(key);
	}

	void clean()
	{
		_store.clean();
	}
}


unittest
{
	__gshared Store store;
	__gshared Cache cache;
	store = new Memory();
	cache = new Cache(store);
	assert(cache.set("test","test") == true);	
	assert(cache.get("test") == "test");	
}
