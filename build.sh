## 开始构建
cmake .. && make

# 清理文件
rm -rf *.a *make* *Make*

# copy需要打包的文件
cp -R ../3rd ../logs ../lualib ../script ../static ../docker ./

mkdir luaclib && mv *.dll luaclib && mv luaclib/*core* .

# copy测试代码依赖的文件
cp ../*.pem ../*.csv ../*.pb .

# copy系统依赖文件
cp /usr/bin/msys-2.0.dll /usr/bin/msys-z.dll /usr/bin/msys-ssl-*.dll /usr/bin/msys-crypto-*.dll ./