# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="91441c3" # Change this when you update the ebuild
EGO_PN="github.com/gogs/gogs"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A painless self-hosted Git service"
HOMEPAGE="https://gogs.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cert memcached mysql openssh pam pie postgres redis sqlite tidb"

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
	sed -i \
		-e "s:^RUN_USER =.*:RUN_USER = gogs:" \
		-e "s:^STATIC_ROOT_PATH =:STATIC_ROOT_PATH = ${EPREFIX}/usr/share/gogs:" \
		-e "s:^ROOT_PATH =:ROOT_PATH = ${EPREFIX}/var/log/gogs:" \
		conf/app.ini || die

	default
}

src_compile() {
	export GOPATH="${G}"
	# build up optional flags
	# shellcheck disable=SC2207
	local options=(
		$(usex cert cert '')
		$(usex pam pam '')
		$(usex sqlite sqlite '')
		$(usex tidb tidb '')
	)
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X '${EGO_PN}/pkg/setting.BuildTime=$(date -u '+%Y-%m-%d %I:%M:%S %Z')'
			-X ${EGO_PN}/pkg/setting.BuildGitHash=${GIT_COMMIT}"
		-tags "${options[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v -cover -race ./... || die
}

src_install() {
	dobin gogs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newtmpfilesd "${FILESDIR}/${PN}.tmpfilesd-r1" "${PN}.conf"

	insinto /var/lib/gogs/conf
	newins conf/app.ini app.ini.example

	insinto /usr/share/gogs
	doins -r templates

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
