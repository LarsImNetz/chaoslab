# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "${PN} only works on amd64"
}

pkg_setup() {
	enewgroup mattermost
	enewuser mattermost -1 -1 -1 mattermost
}

src_prepare() {
	local datadir="${EPREFIX}/var/lib/mattermost"
	# Disable developer settings, fix path, set to listen localhost
	# and disable diagnostics (call home) by default.
	# shellcheck disable=SC2086
	sed -i \
		-e 's|\("ListenAddress":\).*\(8065\).*|\1 "127.0.0.1:\2",|' \
		-e 's|\("ListenAddress":\).*\(8067\).*|\1 "127.0.0.1:\2"|' \
		-e 's|\("EnableDiagnostics":\).*|\1 false|' \
		-e 's|\("Directory":\).*\(/data/\).*|\1 "'${datadir}'\2",|g' \
		-e 's|\("Directory":\).*\(/plugins\).*|\1 "'${datadir}'\2",|' \
		-e 's|\("ClientDirectory":\).*\(/client/plugins\)|\1 "'${datadir}'\2",|' \
		-e 's|tcp(dockerhost:3306)|unix(/run/mysqld/mysqld.sock)|' \
		config/default.json || die

	default
}

src_install() {
	exeinto /usr/libexec/mattermost/bin
	doexe bin/{mattermost,platform}
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd-r1" "${PN/-ee}"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN/-ee}.service"

	insinto /etc/mattermost
	doins config/{README.md,default.json}
	newins config/default.json config.json
	fowners mattermost:mattermost /etc/mattermost/config.json
	fperms 600 /etc/mattermost/config.json

	insinto /usr/share/mattermost
	doins -r {client,fonts,i18n,prepackaged_plugins,templates}

	insinto /usr/share/mattermost/config
	doins config/timezones.json

	diropts -o mattermost -g mattermost -m 0750
	keepdir /var/{lib,log}/mattermost
	keepdir /var/lib/mattermost/client

	dosym ../libexec/mattermost/bin/mattermost /usr/bin/mattermost
	dosym ../../../../etc/mattermost/config.json /usr/libexec/mattermost/config/config.json
	dosym ../../../share/mattermost/config/timezones.json /usr/libexec/mattermost/config/timezones.json
	dosym ../../share/mattermost/fonts /usr/libexec/mattermost/fonts
	dosym ../../share/mattermost/i18n /usr/libexec/mattermost/i18n
	dosym ../../share/mattermost/prepackaged_plugins /usr/libexec/mattermost/prepackaged_plugins
	dosym ../../share/mattermost/templates /usr/libexec/mattermost/templates
	dosym ../../share/mattermost/client /usr/libexec/mattermost/client
	dosym ../../../var/log/mattermost /usr/libexec/mattermost/logs
}
