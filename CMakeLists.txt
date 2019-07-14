# 项目名称
PROJECT(cfadmin C)

# CMAKE最小版本号
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

# 添加头文件查找路径
include_directories(/usr/include)
include_directories(/usr/local/include)

# 添加库文件查找路径
link_directories(/usr/lib)
link_directories(/usr/local/lib)

# 奇怪的错误
#set(CMAKE_MACOSX_RPATH 1)
#set(CMAKE_SKIP_RPATH 1)
#set(SKIP_BUILD_RPATH 1)
#set(CMAKE_SKIP_BUILD_RPATH 1)
#set(CMAKE_SKIP_INSTALL_RPATH 1)

# 设置CFLAGS
set(CMAKE_C_FLAGS "-O3 -fPIC")

# 忽略BUILD目录的rpath
set(CMAKE_SKIP_BUILD_RPATH true)

# 执行文件
set(MAIN
  src/core_start.c
)

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
# ======== 编译第三方luaclib库 ========


# ======== 编译内置cfadmin ========
add_executable(${PROJECT_NAME} ${MAIN})
target_link_libraries(${PROJECT_NAME} core)
# ======== 编译内置luaclib库 ========

install (TARGETS ${PROJECT_NAME} core httpparser cjson lcrypt lpeg tcp udp timer task sys
  RUNTIME DESTINATION "${PROJECT_SOURCE_DIR}"
  LIBRARY DESTINATION "${PROJECT_SOURCE_DIR}/luaclib"
  ARCHIVE DESTINATION "${PROJECT_SOURCE_DIR}"
)
