# 忽略BUILD目录的rpath与win32警告
set(CMAKE_SKIP_BUILD_RPATH true)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

# CMAKE最小版本号
cmake_minimum_required(VERSION 2.6)

# 项目名称
project(cfadmin C)

# 添加头文件查找路径
include_directories(/usr/include)
include_directories(/usr/local/include)

# 添加库文件查找路径
link_directories(/usr/lib)
link_directories(/usr/local/lib)

# 设置CFLAGS
set(CMAKE_C_FLAGS "-O3 -fPIC -Wno-dev")

# 执行文件
set(MAIN src/core_start.c)

# 核心文件
set(CF_SRC_DIR
  src/core_sys.c
  src/core_ev.c
  src/core_memory.c
  src/core.c
)

set(MAIN src/core_start.c)

# luaclib库文件 (内置)
set(CF_LUACLIB_TCP luaclib/src/ltcp.c)
set(CF_LUACLIB_UDP luaclib/src/ludp.c)
set(CF_LUACLIB_TIMER luaclib/src/ltimer.c)
set(CF_LUACLIB_TASK luaclib/src/ltask.c)
set(CF_LUACLIB_SYS luaclib/src/lsys.c)

# luaclib库文件 (第三方)
set(httpparser
  luaclib/src/lhttpparser/httpparser.c
  luaclib/src/lhttpparser/lhttpparser.c
)

set(lcjson
  luaclib/src/lcjson/fpconv.c
  luaclib/src/lcjson/strbuf.c
  luaclib/src/lcjson/lua_cjson.c
)

set(lcrypt
  luaclib/src/lcrypt/crc.c
  luaclib/src/lcrypt/md5.c
  luaclib/src/lcrypt/url.c
  luaclib/src/lcrypt/sha1.c
  luaclib/src/lcrypt/sha2.c
  luaclib/src/lcrypt/lcrypt.c
)

set(lpeg
  luaclib/src/lpeg/lpvm.c
  luaclib/src/lpeg/lpcap.c
  luaclib/src/lpeg/lptree.c
  luaclib/src/lpeg/lpcode.c
  luaclib/src/lpeg/lpprint.c
)

set(lmsgpack
  luaclib/src/lfs/lfs.c
)

set(lmsgpack
  luaclib/src/lmsgpack/lmsgpack.c
)

set(lprotobuf
  luaclib/src/lpbc/lpb.c
)

# ======== 编译核心库 ========
ADD_LIBRARY(core SHARED ${CF_SRC_DIR})
TARGET_LINK_LIBRARIES(core -lev -llua -ldl -lm)
# ======== 编译核心库 ========

# ======== 编译内置luaclib库 ========
ADD_LIBRARY(tcp SHARED ${CF_LUACLIB_TCP})
target_link_libraries(tcp ssl crypto core)

ADD_LIBRARY(udp SHARED ${CF_LUACLIB_UDP})
target_link_libraries(udp core)

ADD_LIBRARY(timer SHARED ${CF_LUACLIB_TIMER})
target_link_libraries(timer core)

ADD_LIBRARY(task SHARED ${CF_LUACLIB_TASK})
target_link_libraries(task core)

ADD_LIBRARY(sys SHARED ${CF_LUACLIB_SYS})
target_link_libraries(sys core)
# ======== 编译内置luaclib库 ========



# ======== 编译第三方luaclib库 ========
ADD_LIBRARY(httpparser SHARED ${httpparser})
target_link_libraries(httpparser core)

ADD_LIBRARY(cjson SHARED ${lcjson})
target_link_libraries(cjson core)

ADD_LIBRARY(lcrypt SHARED ${lcrypt})
target_link_libraries(lcrypt core)

ADD_LIBRARY(lpeg SHARED ${lpeg})
target_link_libraries(lpeg core)

ADD_LIBRARY(lmsgpack SHARED ${lmsgpack})
target_link_libraries(lmsgpack core)

ADD_LIBRARY(lprotobuf SHARED ${lprotobuf})
target_link_libraries(lprotobuf core)

ADD_LIBRARY(lfs SHARED ${lfs})
target_link_libraries(lfs core)
# ======== 编译第三方luaclib库 ========


# ======== 编译内置cfadmin ========
add_executable(${PROJECT_NAME} ${MAIN})
target_link_libraries(${PROJECT_NAME} core)
# ======== 编译内置cfadmin ========


# ========== 说明 ========== #
# 此文件用于作者编译Win版本cfadmin.
# 不提供安装文档与其它技术支持.
# ======================== #
