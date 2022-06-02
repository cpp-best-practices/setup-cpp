read -p "Press enter to install C++ related tools, ctrl-c to cancel" x


sudo pacman -Syu g++ git python-pip cppcheck clang-tidy ccache vscode conan cmake ninja vscode

code --install-extension ms-vscode.cpptools-extension-pack --install-extension jeff-hykin.better-cpp-syntax --install-extension eamodio.gitlens --install-extension jdinhlife.gruvbox

test -f ~/.config/Code/User/settings.json && jq -r '."terminal.integrated.minimumContrastRatio" |= 1' ~/.config/Code/User/settings.json | sponge ~/.config/Code/User/settings.json || echo "{ \"terminal.integrated.minimumContrastRatio\": 1 }" > ~/.config/Code/User/settings.json
