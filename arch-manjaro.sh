read -p "Press enter to install C++ related tools, ctrl-c to cancel" x


sudo pacman -Syu --noconfirm --needed gcc git python-pip cppcheck clang ccache vscode cmake ninja vscode jq moreutils make gdb
pip install --user conan


git clone https://aur.archlinux.org/code-features.git
cd code-features
makepkg -si --noconfirm
cd ..

git clone https://aur.archlinux.org/code-marketplace.git
cd code-marketplace
makepkg -si --noconfirm
cd ..


code --install-extension ms-vscode.cpptools-extension-pack --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox --install-extension xaver.clang-format

test -f ~/.config/Code\ -\ OSS/User/settings.json && jq -r '."terminal.integrated.minimumContrastRatio" |= 1' ~/.config/Code\ -\ OSS/User/settings.json | sponge ~/.config/Code\ -\ OSS/User/settings.json || echo "{ \"terminal.integrated.minimumContrastRatio\": 1 }" > ~/.config/Code\ -\ OSS/User/settings.json
