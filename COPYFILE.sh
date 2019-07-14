# copy需要打包的文件
cp ../3rd ./
cp ../logs ./
cp ../lualib ./
cp ../script ./

mkdir luaclib && mv *.dll luaclib/ && mv luaclib/*core.dll ./

# copy系统依赖文件
cp /usr/bin/msys-2.0.dll ./
cp /usr/bin/msys-z.dll ./
cp /usr/bin/msys-ssl-*.dll ./
cp /usr/bin/msys-crypto-*.dll ./
