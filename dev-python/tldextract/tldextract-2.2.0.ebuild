# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )

inherit distutils-r1

DESCRIPTION="Accurately separates the gTLD or ccTLD from the registered domain and subdomains"
HOMEPAGE="https://github.com/john-kurkowski/tldextract"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-python/idna[${PYTHON_USEDEP}]
	>=dev-python/requests-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/requests-file-1.4[${PYTHON_USEDEP}]
	python_targets_python2_7? ( dev-python/configargparse[$(python_gen_usedep 'python2*')] )"

#python_test() {
#	esetup.py test
#}
