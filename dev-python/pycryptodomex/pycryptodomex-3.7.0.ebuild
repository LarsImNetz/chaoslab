# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} pypy{,3} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="A self-contained (and independent) cryptographic library for Python"
HOMEPAGE="https://www.pycryptodome.org https://github.com/Legrandin/pycryptodome"
SRC_URI="mirror://pypi/p/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD-2 Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~x86 ~ppc-aix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	dev-libs/gmp:0
	virtual/python-cffi[${PYTHON_USEDEP}]
	!dev-python/pycryptodome
"

python_test() {
	esetup.py test
}
