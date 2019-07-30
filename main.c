#include <stdio.h>
#include <unistd.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#if LUA_VERSION_NUM >= 504
  #define CO_RESUME(L, from, nargs) ({int nout = 0; lua_resume(L, from, nargs, &nout);})
#else
  #define CO_RESUME(L, from, nargs) lua_resume(L, from, nargs)
#endif

int main(int argc, char const *argv[]) {
  lua_State *L = luaL_newstate();
  if (!L) return 0;
  luaL_openlibs(L);
  int state = 0;
  state = luaL_loadstring(L,
    " print(_G._VERSION) "                \
    " local function f () "               \
    " while 1 do "                        \
    " print(coroutine.yield()) "          \
    " end "                               \
    " end "                               \
    " return coroutine.create(f) "
  );

  if (state > 1) {
    printf("error 0 : %s\n", lua_tostring(L, -1));
    return -1;
  }

  state = CO_RESUME(L, NULL, 0);
  if (state > 1) {
    printf("error 1 : %s\n", lua_tostring(L, -1));
    return -1;
  }

  lua_State *co = lua_tothread(L, 1);

  state = CO_RESUME(co, NULL, 0);
  if (state > 1) {
    printf("error 2 : %s\n", lua_tostring(L, -1));
    return -1;
  }

  int times = 10;
  while (times) {
    sleep(1);
    lua_pushinteger(co, times);
    state = CO_RESUME(co, NULL, 1);
    if (state > 1) {
      printf("error 2 : %s\n", lua_tostring(L, -1));
      return -1;
    }
    times--;
  }

  lua_close(L);
  return 0;
}
