# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 multilib

DESCRIPTION="LDAP client API for Python"
HOMEPAGE="https://github.com/python-ldap/python-ldap"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="examples sasl ssl"

RDEPEND=">net-nds/openldap-2.4.11
	dev-python/pyasn1[${PYTHON_USEDEP}]
	dev-python/pyasn1-modules[${PYTHON_USEDEP}]
	sasl? ( >=dev-libs/cyrus-sasl-2.1 )"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND+=" !dev-python/pyldap"

python_prepare_all() {
	sed -e "s:^# library_dirs =.*:library_dirs = /usr/$(get_libdir) /usr/$(get_libdir)/sasl2:" \
		-e "s:^# include_dirs =.*:include_dirs = /usr/include /usr/include/sasl:" \
		-i setup.cfg || die "error fixing setup.cfg"

	local mylibs="ldap"
	if use sasl; then
		use ssl && mylibs="ldap_r"
		mylibs="${mylibs} sasl2"
	else
		sed -e 's/HAVE_SASL//g' -i setup.cfg || die
	fi
	use ssl && mylibs="${mylibs} ssl crypto"
	use elibc_glibc && mylibs="${mylibs} resolv"

	sed -e "s:^libs = .*:libs = lber ${mylibs}:" \
		-i setup.cfg || die "error setting up libs in setup.cfg"

	# shellcheck disable=SC1117
	# set test expected to fail to expectedFailure
	sed -e "s:^    def test_bad_urls:    @unittest.expectedFailure\n    def test_bad_urls:" \
		-i Tests/t_ldapurl.py || die

	distutils-r1_python_prepare_all
}

python_test() {
	# XXX: the tests supposedly can start local slapd
	# but it requires some manual config, it seems.

	"${PYTHON}" Tests/t_ldapurl.py || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	use examples && local EXAMPLES=( Demo/. )

	distutils-r1_python_install_all
}
