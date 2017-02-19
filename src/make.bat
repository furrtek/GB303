cd D:\Gameboy\gb303-pub\trunk

if exist main.gb del main.gb
if exist main.o del main.o

"D:\Program Files\WLA-DX\wla-gb.exe" -ox main.s main.o

echo [objects]>linkfile
echo main.o>>linkfile

"D:\Program Files\WLA-DX\wlalink.exe" -vs linkfile main.gb
