# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_REQ_USE='sqlite?,threads(+)'

inherit distutils-r1 user

DESCRIPTION="A mail hosting and management platform with a modern and simplified Web UI"
HOMEPAGE="https://modoboa.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="gunicorn ldap mysql postgres sqlite"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="
	<=dev-python/django-1.11.99[${PYTHON_USEDEP}]
	>=dev-python/django-1.11.8[${PYTHON_USEDEP}]
	~dev-python/django-braces-1.11.0[${PYTHON_USEDEP}]
	~dev-python/django-ckeditor-5.2.2[${PYTHON_USEDEP}]
	~dev-python/django-reversion-2.0.12[${PYTHON_USEDEP}]
	~dev-python/django-subcommand2-0.1.1[${PYTHON_USEDEP}]
	~dev-python/django-xforwardedfor-middleware-2.0[${PYTHON_USEDEP}]
	dev-python/dj-database-url[${PYTHON_USEDEP}]
	~dev-python/coreapi-2.3.3[${PYTHON_USEDEP}]
	~dev-python/coreapi-cli-1.0.6[${PYTHON_USEDEP}]
	~dev-python/djangorestframework-3.7.3[${PYTHON_USEDEP}]
	~dev-python/bcrypt-3.1.4[${PYTHON_USEDEP}]
	~dev-python/dnspython-1.15.0[${PYTHON_USEDEP}]
	~dev-python/feedparser-5.2.1[${PYTHON_USEDEP}]
	~dev-python/gevent-1.2.2[${PYTHON_USEDEP}]
	~dev-python/jsonfield-2.0.2[${PYTHON_USEDEP}]
	~dev-python/passlib-1.7.1[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	~dev-python/progressbar33-2.4[${PYTHON_USEDEP}]
	~dev-python/py-dateutil-2.2[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/rfc6266[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
	virtual/python-ipaddress[${PYTHON_USEDEP}]
	gunicorn? ( www-servers/gunicorn[${PYTHON_USEDEP}] )
	ldap? ( >=dev-python/django-auth-ldap-1.3.0[${PYTHON_USEDEP}] )
	mysql? ( dev-python/mysqlclient[${PYTHON_USEDEP}] )
	postgres? ( >=dev-python/psycopg-2.7.4:2[${PYTHON_USEDEP}] )
	python_targets_python2_7? (
		dev-python/backports-csv[python_targets_python2_7]
	)
"

PATCHES=( "${FILESDIR}/${P}-setup.patch" )

pkg_setup() {
	if use gunicorn; then
		enewgroup modoboa
		enewuser modoboa -1 -1 /var/lib/modoboa modoboa
	fi
}

src_install() {
	distutils-r1_src_install

	if use gunicorn; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"

		insinto /etc/modoboa
		newins "${FILESDIR}"/modoboa.conf modoboa.conf.example

		diropts -o modoboa -g modoboa -m 0750
		keepdir /var/log/modoboa
	fi
}
