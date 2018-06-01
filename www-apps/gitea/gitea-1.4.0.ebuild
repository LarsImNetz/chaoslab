# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=( "github.com/jteeuwen/go-bindata a0ff256" )

inherit golang-vcs-snapshot systemd user

EGO_PN="code.gitea.io/gitea"
DESCRIPTION="Gitea - Git with a cup of tea"
HOMEPAGE="https://gitea.io"
SRC_URI="https://github.com/go-gitea/gitea/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="memcached mysql openssh pam postgres redis sqlite tidb"

RDEPEND="dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
	tidb? ( dev-db/tidb )"
RESTRICT="mirror strip"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup git
	enewuser git -1 /bin/bash /var/lib/gitea git
}

src_prepare() {
	local GITEA_PREFIX="${EPREFIX}/var/lib/gitea"

	sed -i -e "s:^TEMP_PATH =.*:TEMP_PATH = ${GITEA_PREFIX}/data/tmp/uploads:" \
		-e "s:^STATIC_ROOT_PATH =:STATIC_ROOT_PATH = ${EPREFIX}/usr/share/gitea:" \
		-e "s:^APP_DATA_PATH =.*:APP_DATA_PATH = ${GITEA_PREFIX}/data:" \
		-e "s:^PATH = data/gitea.db:PATH = ${GITEA_PREFIX}/data/gitea.db:" \
		-e "s:^ISSUE_INDEXER_PATH =.*:ISSUE_INDEXER_PATH = ${GITEA_PREFIX}/indexers/issues.bleve:" \
		-e "s:^PROVIDER_CONFIG =.*:PROVIDER_CONFIG = ${GITEA_PREFIX}/data/sessions:" \
		-e "s:^AVATAR_UPLOAD_PATH =.*:AVATAR_UPLOAD_PATH = ${GITEA_PREFIX}/data/avatars:" \
		-e "s:^PATH = data/attachments:PATH = ${GITEA_PREFIX}/data/attachments:" \
		-e "s:^ROOT_PATH =:ROOT_PATH = ${EPREFIX}/var/log/gitea:" \
		custom/conf/app.ini.sample || die

	sed -i 's:Version=.*:Version='${PV}'" -X "main.Tags=$(TAGS)":' \
		Makefile || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local PATH="${G}/bin:$PATH" TAGS_OPTS=

	ebegin "Building go-bindata locally"
	pushd vendor/github.com/jteeuwen/go-bindata > /dev/null || die
	go build -v -ldflags "-s -w" -o \
		"${G}"/bin/go-bindata ./go-bindata || die
	popd > /dev/null || die
	eend $?

	use pam && TAGS_OPTS+=" pam"
	use sqlite && TAGS_OPTS+=" sqlite"
	use tidb && TAGS_OPTS+=" tidb"

	TAGS="${TAGS_OPTS/ /}" \
	emake generate build
}

src_test() {
	go test -v $(go list ./... | grep -v /integrations) || die
}

src_install() {
	dobin gitea

	newinitd "${FILESDIR}"/${PN}.initd-r4 ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd-r1 ${PN}.conf

	insinto /var/lib/gitea/conf
	newins custom/conf/app.ini.sample app.ini.example
	doins -r options/*

	insinto /usr/share/gitea
	doins -r {public,templates}

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate ${PN}

	diropts -m 0750
	dodir /var/lib/gitea/data /var/log/gitea
	fowners -R git:git /var/{lib,log}/gitea
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/var/lib/gitea/conf/app.ini ]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT%/}"/var/lib/gitea/conf/app.ini{.example,} || die
	else
		elog "app.ini found, please check example file for possible changes"
	fi
}
