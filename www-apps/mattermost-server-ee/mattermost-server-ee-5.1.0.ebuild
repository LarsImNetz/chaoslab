# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd user

DESCRIPTION="Open source Slack-alternative in Golang and React (Enterprise Edition)"
HOMEPAGE="https://mattermost.com"
SRC_URI="https://releases.mattermost.com/${PV}/mattermost-${PV}-linux-amd64.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Mattermost-EE"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="!www-apps/mattermost-server"

DOCS=( NOTICE.txt README.md )

S="${WORKDIR}/mattermost"

pkg_setup() {
	enewgroup mattermost
	enewuser mattermost -1 -1 -1 mattermost
}

src_prepare() {
	# shellcheck disable=SC2086
	# Disable developer settings, fix path, set to listen localhost and disable
	# diagnostics (call home) by default.
	sed -i \
		-e 's|"ListenAddress": ":8065"|"ListenAddress": "127.0.0.1:8065"|g' \
		-e 's|"ListenAddress": ":8067"|"ListenAddress": "127.0.0.1:8067"|g' \
		-e 's|"EnableDiagnostics":.*|"EnableDiagnostics": false|' \
		-e 's|"Directory": "./data/"|"Directory": "'${EPREFIX}'/var/lib/mattermost/data/"|g' \
		-e 's|"Directory": "./plugins"|"Directory": "'${EPREFIX}'/var/lib/mattermost/plugins"|g' \
		-e 's|"ClientDirectory": "./client/plugins"|"ClientDirectory": "'${EPREFIX}'/var/lib/mattermost/client/plugins"|g' \
		-e 's|tcp(dockerhost:3306)|unix(/run/mysqld/mysqld.sock)|g' \
		config/default.json || die

	default
}

src_install() {
	exeinto /usr/libexec/mattermost/bin
	doexe bin/{mattermost,platform}
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN/-ee}"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN/-ee}.service"

	insinto /etc/mattermost
	doins config/{README.md,default.json}
	newins config/default.json config.json
	fowners mattermost:mattermost /etc/mattermost/config.json
	fperms 600 /etc/mattermost/config.json

	insinto /usr/share/mattermost
	doins -r {fonts,i18n,templates}

	insinto /usr/share/mattermost/config
	doins config/timezones.json

	insinto /usr/share/mattermost/client
	doins -r client/*

	diropts -o mattermost -g mattermost -m 0750
	keepdir /var/{lib,log}/mattermost

	dosym ../libexec/mattermost/bin/mattermost /usr/bin/mattermost
	dosym ../../../../etc/mattermost/config.json /usr/libexec/mattermost/config/config.json
	dosym ../../../share/mattermost/config/timezones.json /usr/libexec/mattermost/config/timezones.json
	dosym ../../share/mattermost/fonts /usr/libexec/mattermost/fonts
	dosym ../../share/mattermost/i18n /usr/libexec/mattermost/i18n
	dosym ../../share/mattermost/templates /usr/libexec/mattermost/templates
	dosym ../../share/mattermost/client /usr/libexec/mattermost/client
	dosym ../../../var/log/mattermost /usr/libexec/mattermost/logs
}
