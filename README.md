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
Set-ExecutionPolicy Bypass -scope Process -Force
Import-Module BitsTransfer
Start-BitsTransfer -Source "https://raw.githubusercontent.com/mguludag/setup-cpp/main/windows.ps1" -Destination $pwd/windows.ps1
./windows.ps1
```
