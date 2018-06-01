# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="A reusable JSONField model for Django to store ad-hoc data"
HOMEPAGE="https://github.com/dmkoch/django-jsonfield"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"

DEPEND="test? ( dev-python/django[${PYTHON_USEDEP}] )"

python_test() {
	esetup.py test
}
