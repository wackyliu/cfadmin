# 清理文件
rm -rf *.a *make* *Make*

# copy需要打包的文件
cp -R ../3rd ./
cp -R ../logs ./
cp -R ../lualib ./
cp -R ../script ./
cp -R ../static ./

mkdir luaclib && mv *.dll luaclib/ && mv luaclib/*core.dll ./

# copy系统依赖文件
cp /usr/bin/msys-2.0.dll ./
cp /usr/bin/msys-z.dll ./
cp /usr/bin/msys-ssl-*.dll ./
cp /usr/bin/msys-crypto-*.dll ./
