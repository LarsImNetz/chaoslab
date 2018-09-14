# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd user

GIT_COMMIT="b5d5504" # Change this when you update the ebuild
EGO_PN="github.com/mattermost/${PN}"
MMWAPP_PN="mattermost-webapp"
MMWAPP_P="${MMWAPP_PN}-${PV}"

DESCRIPTION="Open source Slack-alternative in Golang and React (Team Edition)"
HOMEPAGE="https://mattermost.com"
SRC_URI="
	https://github.com/mattermost/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/mattermost/${MMWAPP_PN}/archive/v${PV}.tar.gz -> ${MMWAPP_P}.tar.gz
"
RESTRICT="mirror test"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DEPEND="
	>=dev-lang/go-1.10.1
	>=net-libs/nodejs-6.0.0
"
RDEPEND="!www-apps/mattermost-server-ee"

QA_PRESTRIPPED="
	usr/libexec/mattermost/bin/mattermost
	usr/libexec/mattermost/bin/platform
"

G="${WORKDIR}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi

	enewgroup mattermost
	enewuser mattermost -1 -1 -1 mattermost
}

src_unpack() {
	default

	mkdir -p "${G}/src/${EGO_PN/$PN}" || die
	mv "${WORKDIR}/${P}" "${S}" || die
	mv "${WORKDIR}/${MMWAPP_P}" "${S}"/client || die
}

src_prepare() {
	# shellcheck disable=SC2086
	# Disable developer settings, fix path, set to listen localhost and disable
	# diagnostics (call home) by default.
	sed -i \
		-e 's|"ListenAddress": ":8065"|"ListenAddress": "127.0.0.1:8065"|g' \
		-e 's|"ListenAddress": ":8067"|"ListenAddress": "127.0.0.1:8067"|g' \
		-e 's|"ConsoleLevel": "DEBUG"|"ConsoleLevel": "INFO"|g' \
		-e 's|"EnableDiagnostics":.*|"EnableDiagnostics": false|' \
		-e 's|"Directory": "./data/"|"Directory": "'${EPREFIX}'/var/lib/mattermost/data/"|g' \
		-e 's|"Directory": "./plugins"|"Directory": "'${EPREFIX}'/var/lib/mattermost/plugins"|g' \
		-e 's|"ClientDirectory": "./client/plugins"|"ClientDirectory": "'${EPREFIX}'/var/lib/mattermost/client/plugins"|g' \
		-e 's|tcp(dockerhost:3306)|unix(/run/mysqld/mysqld.sock)|g' \
		config/default.json || die

	# Reset email sending to original configuration
	sed -i \
		-e 's|"SendEmailNotifications": true,|"SendEmailNotifications": false,|g' \
		-e 's|"FeedbackEmail": "test@example.com",|"FeedbackEmail": "",|g' \
		-e 's|"SMTPServer": "dockerhost",|"SMTPServer": "",|g' \
		-e 's|"SMTPPort": "2500",|"SMTPPort": "",|g' \
		config/default.json || die

	default
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local myldflags=( -s -w
		-X "${EGO_PN}/model.BuildNumber=${PV}"
		-X "'${EGO_PN}/model.BuildDate=$(date -u)'"
		-X "${EGO_PN}/model.BuildHash=${GIT_COMMIT}"
		-X "${EGO_PN}/model.BuildHashEnterprise=none"
		-X "${EGO_PN}/model.BuildEnterpriseReady=false"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)

	emake -C client build

	go install "${mygoargs[@]}" ./cmd/{mattermost,platform} || die
}

src_install() {
	exeinto /usr/libexec/mattermost/bin
	doexe mattermost platform

	newinitd "${FILESDIR}/${PN}.initd-r1" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

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
	doins -r client/dist/*

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
