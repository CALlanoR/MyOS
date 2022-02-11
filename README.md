make 
make install
make run

tar --exclude=".gitignore" --exclude=".git" -cvzf MyOS.tgz MyOS -R