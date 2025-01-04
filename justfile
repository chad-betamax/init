mod apt "modules/apt.just"
mod dra "modules/dra.just"


_default:
    @just --list

_paths :="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
_boxinit:
    @echo 'PATH="{{ _paths }}"' | sudo tee /etc/environment > /dev/null


[group('install')]
apt-installs: 
    # Apt installs
    # #############################################

    @just apt::initialise

    @just apt::get "git"
    @just apt::get "tmux"
    @just apt::get "traceroute"
    @just apt::get "xclip"
    @just apt::get "nmap"
    @just apt::get "htop"
    @just apt::get "members"
    @just apt::get "keychain"
    @just apt::get "jq"
    @just apt::get "direnv"
    @just apt::get "tree"
    @just apt::get "openssh-server"
    @just apt::get "sshfs"

_dra := "https://github.com/devmatteini/dra/releases/download/0.7.0/dra_0.7.0-1_amd64.deb"
_rust := "https://sh.rustup.rs"
[group('install')]
curl-installs:
    # Curl installs
    # #############################################

    # Install rust
    @curl --proto '=https' --tlsv1.2 {{ _rust }} --silent --show-error --fail|sh -s -- -y --no-modify-path

    # Install dra
    @curl --silent --show-error --location {{ _dra }} --output-dir /tmp --output dra.deb
    @sudo dpkg --install /tmp/dra.deb


[group('install')]
dra-installs:
    # Dra installs
    # #############################################

    # rage encryption, used by chezmoi
    @just dra::multi "str4d/rage" "rage rage-keygen rage-mount"

    # chezmoi a dotfile manager
    @sudo rm /usr/local/bin/chezmoi* 2>/dev/null
    @just dra::install "twpayne/chezmoi" 
    @sudo mv /usr/local/bin/chezmoi* /usr/local/bin/chezmoi 

    # dra can't install neovim as it creates dirs, use as a downloader only
    @just dra::download "neovim/neovim"
    # tar extract into /opt
    @sudo tar --directory /opt -xzf /tmp/nvim*.tar.gz

    # rg, a faster grep
    @just dra::install "BurntSushi/ripgrep" 

    # bat, cat with syntax highlighting
    @just dra::install "sharkdp/bat"

    #faster find
    @just dra::install "sharkdp/fd"

    # delta, syntax highlighting for git, diff and grep output 
    @just dra::install "dandavison/delta" 


# Install all the things
[group('install')]
install: _boxinit apt-installs curl-installs dra-installs

[group('config')]
_dotfiles:
    @just chezmoi 
    @echo dotfiles...

[group('config')]
_plugins:
    @echo plugins...


# deploy dotfiles and plugins for all your programs
[group('config')]
configs: _dotfiles _plugins
    @echo "All done!"

# misc tidy up
[group('config')]
tidy:
    @rmdir ~/Public ~/Templates ~/Videos 

#still to do
# configs
# figger out where age key will be sourced from
# chezmoi completions
# tmux plugins
# neovim plugins
# source bashrc


