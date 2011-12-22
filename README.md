使用说明
=============

克隆,编译
命令行运行程序
command: bStrings [-o out] [src]  [-a]
-o :   指明输出文件
out:  如果是文件，所有plist中提取的字符串都将存放到这个文件中。
     如果是文件夹，每个plist的字符串提取到文件夹中对应的文件里面(对应的文件会自动创建)。
            如果out地址不存在，则指向当前目录。
src  指向需要国际化的plist文件或存放这些plist文件的目录。不存在的话指向当前目录。
-a:   追加模式，如果输出文件已经存在，那么新内容添加在结尾。否则就是清空在写。
注意：plist 特指Setting.bundle里面的plist文件。


How to use
=============

clone and build
run the binary file use follow command
command: bStrings [-o out] [src]  [-a]
-o :   point to the file which will store the string we pick up
out:   if is a file, string picked up from any plist file will put in it.
       if is a foldar,every plist will have a corresponding file in the foldar(app will create one if it not exist)
	if the address is not exist,it will point to current folder.
src   point to a plist file of Setting.bundle or a foldar that store some that kind plist.
	if the address is not exist,it will point to current folder.
-a:   append mode,if the output file is already exist,the new content will append at the end of the file.Not sign this,the exist file will empty old content.
Notice：plist is special mean the plist files in Setting.bundle.

