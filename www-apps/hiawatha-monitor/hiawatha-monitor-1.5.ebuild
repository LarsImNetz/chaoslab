# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Monitoring application for www-servers/hiawatha"
HOMEPAGE="https://www.hiawatha-webserver.org/howto/monitor"
SRC_URI="https://www.hiawatha-webserver.org/files/monitor-${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-lang/php[mysql,xslt]
	virtual/cron
	virtual/mysql
	www-servers/hiawatha[xslt]"

S="${WORKDIR}/monitor"

src_install () {
	rm -f ChangeLog README LICENSE || die

	insinto "/usr/share/${PN}"
	doins -r ./*
}
