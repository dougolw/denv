#!/bin/bash

echo "i3 or plasma?"
select os in "i3" "plasma"; do
   case $os in
      i3 )
         os=i3; break;;
      plasma )
         os=plasma; break;;
   esac
done

distro=$(grep -E '^(PRETTY_NAME|NAME)=' /etc/os-release)
GIT_DIR=$(find $HOME -name "git" -type d)

mkdir $HOME/.clones
mkdir $HOME/.i3
sudo mkdir -p /usr/local/share/lombok

findGitFile() {
   find $GIT_DIR -name $1 -type f
}

findDir() {
   find $GIT_DIR -name $1 -type d
}

createSymlink () {
   ln -s $(findGitFile $1) $2
}

sudo pacman -S --noconfirm xorg xorg-xinit neovim tmux alacritty ttf-dejavu mpv
sudo pacman -S --noconfirm openjdk17-doc java17-openjfx stack haskell-language-server 
sudo pacman -S --noconfirm fish tree mariadb dbeaver lazygit wget uvicorn unzip
sudo pacman -S --noconfirm fzf github-cli docker docker-compose cabal-install
sudo pacman -S --noconfirm neofetch npm atril deepin-image-viewer deepin-screenshot
sudo pacman -S --noconfirm nvidia xf86-video-amdgpu obs-studio code python-pip

if [[ $distro == *'Parabola'* ]]; then
   sudo pacman -S --noconfirm icecat pulseaudio pavucontrol
   echo "bindsym \$mod1+g exec icecat" >> ./.i3/config

elif [[ $distro == *'Arch'* ]]; then
   git clone https://aur.archlinux.org/google-chrome.git $HOME/.clones/google-chrome
   (cd $HOME/.clones/google-chrome && makepkg -si --noconfirm)
   echo "bindsym \$mod1+g exec google-chrome-stable" >> ./.i3/config
fi

if [[ $os == 'i3' ]]; then
   sudo pacman -S --noconfirm i3 feh
   echo "exec i3" > $HOME/.xinitrc
   createSymlink "config" "$HOME/.i3"
   createSymlink ".i3status.conf" "$HOME"
   echo -e "\nexec --no-startup-id feh --bg-fill $HOME/git/toolazy/got/wallpapers/see.jpg" >> $HOME/.i3/config
elif [[ $os == 'plasma' ]]; then
   sudo pacman -S --noconfirm plasma
   echo "export DESKTOP_SESSION=plasma\nexec startplasma-x11" > $HOME/.xinitrc
   git clone https://github.com/Prayag2/kde_onedark "$HOME/.clones/kde_onedark"
   sh $HOME/.clones/kde_onedark/install --noconfirm
   for config in $(findDir "kde")/*; do
      ln -s $config $HOME/.config
   done
fi

pip install mariadb mypy telebot yfinance python-binance 
sudo npm i -g neovim pyright sass node-fetch @angular/cli

while read repo; do
   dir="$(echo "$repo" | awk -F '/' '{print $NF}')"
   git clone https://github.com/"$repo" "$HOME/.clones/$dir"
done < packages/repos.txt

curl -fLo ~/.vim/plug/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo wget https://projectlombok.org/downloads/lombok.jar \
   -O /usr/local/share/lombok/lombok.jar
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

createSymlink ".alacritty.yml" "$HOME"
createSymlink ".gitconfig" "$HOME"
createSymlink ".tmux.conf" "$HOME"
createSymlink ".vimrc" "$HOME"
createSymlink ".gitconfig" "$HOME"
createSymlink "coc-settings.json" "$HOME/.vim"
createSymlink "config.fish" "$HOME/.config/fish"

# Fish functions link
for fun in $(findDir "functions")/*; do
   ln -s $fun $HOME/.config/fish/functions
done

nvim -u ~/.vimrc -c "PlugInstall" -c "sleep 30" -c "q!" -c "q!"

nvim -u ~/.vimrc -c "autocmd VimEnter * CocInstall coc-tsserver coc-java coc-json coc-pyright coc-git coc-sh coc-html coc-css coc-snippets coc-vimlsp | sleep 180 | q! | q!"
