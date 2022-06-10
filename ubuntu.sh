read -p "Press enter to install C++ related tools, ctrl-c to cancel" x

sudo apt update -y

sudo apt upgrade -y

sudo apt install -y jq g++-11 git python3 python3-pip cppcheck clang-tidy-13 clang-tidy clang-format ccache moreutils

pip install --user conan ninja cmake

echo "Installing vscode via snap or straight from deb package if necessary"
sudo snap install code --classic || (wget https://code.visualstudio.com/sha/download?build=stable\&os=linux-deb-arm64 -O vscode.deb && sudo dpkg -i vscode.deb)

sudo apt -f install

code --install-extension ms-vscode.cpptools-extension-pack --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox --install-extension xaver.clang-format

test -f ~/.config/Code/User/settings.json && jq -r '."terminal.integrated.minimumContrastRatio" |= 1' ~/.config/Code/User/settings.json | sponge ~/.config/Code/User/settings.json || echo "{ \"terminal.integrated.minimumContrastRatio\": 1 }" > ~/.config/Code/User/settings.json
