# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )

inherit distutils-r1

DESCRIPTION="Django LDAP authentication backend"
HOMEPAGE="https://github.com/django-auth-ldap/django-auth-ldap"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="
	>=dev-python/django-1.11.0[${PYTHON_USEDEP}]
	dev-python/flake8[${PYTHON_USEDEP}]
	dev-python/isort[${PYTHON_USEDEP}]
	>=dev-python/mock-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/python-ldap-3.0[${PYTHON_USEDEP}]
"
