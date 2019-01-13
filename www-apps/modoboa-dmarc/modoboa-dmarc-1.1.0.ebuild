# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="A set of tools to use DMARC through Modoboa"
HOMEPAGE="https://modoboa.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="dev-python/setuptools_scm[${PYTHON_USEDEP}]"
RDEPEND="
	>=www-apps/modoboa-1.10.0[${PYTHON_USEDEP}]
	>=dev-python/tldextract-2.0.2[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	python_targets_python2_7? (
		>=dev-python/futures-3.1.0[python_targets_python2_7]
	)
"

PATCHES=( "${FILESDIR}/${P}-setup.patch" )
