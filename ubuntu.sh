sudo apt update -y

sudo apt upgrade -y

sudo apt install -y jq g++-11 git python3 python3-pip cppcheck clang-tidy-13 clang-tidy ccache moreutils

pip install --user conan ninja cmake

sudo snap install code --classic

code --install-extension ms-vscode.cpptools-extension-pack --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox

test -f ~/.config/Code/User/settings.json && jq -r '."terminal.integrated.minimumContrastRatio" |= 1' ~/.config/Code/User/settings.json | sponge ~/.config/Code/User/settings.json || echo "{ \"terminal.integrated.minimumContrastRatio\": 1 }" > ~/.config/Code/User/settings.json
