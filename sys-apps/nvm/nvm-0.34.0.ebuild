# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A simple bash script to manage multiple active node.js versions"
HOMEPAGE="https://github.com/creationix/nvm"
SRC_URI="https://github.com/creationix/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

src_compile() {
	:;
}

src_install() {
	local NVM_HOME="/usr/share/nvm"
	exeinto "${NVM_HOME}"
	doexe nvm-exec

	insinto "${NVM_HOME}"
	doins nvm.sh
	doins bash_completion
	doins "${FILESDIR}"/init-nvm.sh
	doins "${FILESDIR}"/install-nvm-exec
}
