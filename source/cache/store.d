module cache.store;

import cache;

abstract class Store
{
	bool set(string key,ubyte[] value);
	ubyte[] get(string key);
	bool isset(string key);
	bool remove(string key);
	void clean();
}
