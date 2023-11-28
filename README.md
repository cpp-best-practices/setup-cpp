# setup-cpp
Some tools for getting C++ configured on various platforms.

## Ubuntu Linux

```sh
bash <(wget -qO- https://raw.githubusercontent.com/cpp-best-practices/setup-cpp/main/ubuntu.sh)
```

## Arch Linux (including Manjaro)

```sh
bash <(wget -qO- https://raw.githubusercontent.com/cpp-best-practices/setup-cpp/main/arch-manjaro.sh)
```

## Windows (10/11)

```powershell
Set-ExecutionPolicy RemoteSigned -scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mguludag/setup-cpp/main/windows.ps1" -OutFile $pwd/windows.ps1
./windows.ps1
exit
```
