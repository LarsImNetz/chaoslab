# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="2978bb1" # Change this when you update the ebuild
EGO_PN="github.com/gogits/gogs"
EGO_VENDOR=( "github.com/kevinburke/go-bindata 2197b05" )

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A painless self-hosted Git service"
HOMEPAGE="https://gogs.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cert memcached mysql openssh pam postgres redis sqlite tidb"

RDEPEND="dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
	tidb? ( dev-db/tidb )"

QA_PRESTRIPPED="usr/bin/gogs"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup gogs
	enewuser gogs -1 /bin/bash /var/lib/gogs gogs
}

src_prepare() {
	local GOGS_PREFIX="${EPREFIX}/var/lib/gogs"
	sed -i \
		-e "s:^RUN_USER =.*:RUN_USER = gogs:" \
		-e "s:^ROOT =:ROOT = ${GOGS_PREFIX}/repos:" \
		-e "s:^TEMP_PATH =.*:TEMP_PATH = ${GOGS_PREFIX}/data/tmp/uploads:" \
		-e "s:^STATIC_ROOT_PATH =:STATIC_ROOT_PATH = ${EPREFIX}/usr/share/gogs:" \
		-e "s:^APP_DATA_PATH =.*:APP_DATA_PATH = ${GOGS_PREFIX}/data:" \
		-e "s:^PATH = data/gogs.db:PATH = ${GOGS_PREFIX}/data/gogs.db:" \
		-e "s:^PROVIDER_CONFIG =.*:PROVIDER_CONFIG = ${GOGS_PREFIX}/data/sessions:" \
		-e "s:^AVATAR_UPLOAD_PATH =.*:AVATAR_UPLOAD_PATH = ${GOGS_PREFIX}/data/avatars:" \
		-e "s:^PATH = data/attachments:PATH = ${GOGS_PREFIX}/data/attachments:" \
		-e "s:^ROOT_PATH =:ROOT_PATH = ${EPREFIX}/var/log/gogs:" \
		conf/app.ini || die

	sed -i "s:GitHash=.*:GitHash=${GIT_COMMIT}\":" \
		Makefile || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH"

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die

	# shellcheck disable=SC2207
	# build up optional flags
	local options=(
		$(usex cert cert '')
		$(usex pam pam '')
		$(usex sqlite sqlite '')
		$(usex tidb tidb '')
	)

	emake \
		LDFLAGS="-s -w" \
		TAGS="${options[*]}" \
		build
}

src_test() {
	go test -v -cover -race ./... || die
}

src_install() {
	dobin gogs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newtmpfilesd "${FILESDIR}/${PN}.tmpfilesd-r1" "${PN}.conf"

	insinto /var/lib/gogs/conf
	newins conf/app.ini app.ini.example

	insinto /usr/share/gogs
	doins -r {conf,templates}

	insinto /usr/share/gogs/public
	doins -r public/{assets,css,img,js,plugins}

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate-r1" "${PN}"

	diropts -m 0750
	keepdir /var/lib/gogs/data /var/log/gogs
	fowners -R gogs:gogs /var/{lib,log}/gogs
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/var/lib/gogs/conf/app.ini ]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT%/}"/var/lib/gogs/conf/app.ini{.example,} || die
	else
		elog "app.ini found, please check example file for possible changes"
	fi
}
