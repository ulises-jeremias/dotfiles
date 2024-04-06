# Maintainer: Ulises Jeremias Cornejo Fandos <ulisescf.24@gmail.com>

pkgname=dots-stable
pkgver=1.2.2
pkgrel=1
pkgdesc="HorneroConfig - Comprehensive Dotfiles Framework"
arch=(any)
url="https://github.com/ulises-jeremias/dotfiles"
license=('MIT')
depends=(git chezmoi)
optdepends=()
provides=(dots)
conflicts=(dots)
source=("git+$url.git")
md5sums=('SKIP')

pkgver() {
	cd dotfiles || exit
	git describe --tags "$(git rev-list --tags --max-count=1)" | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

package() {
	cd dotfiles || exit
	git fetch --tags
	latest_release=$(git describe --tags "$(git rev-list --tags --max-count=1)")
	git checkout "${latest_release}"
	cd ..

	if [[ ! -d "${HOME}/.dotfiles" ]]; then
		cp -rf ./dotfiles ~/.dotfiles
	fi

	chezmoi init --apply --verbose --force --source ~/.dotfiles
}
