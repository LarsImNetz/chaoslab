# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="code.gitea.io/${PN}"
EGO_VENDOR=( "github.com/kevinburke/go-bindata v3.13.0" )

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Gitea - Git with a cup of tea"
HOMEPAGE="https://gitea.io"
ARCHIVE_URI="https://github.com/go-${PN}/${PN}/archive/v${PV/_/-}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bindata debug memcached mysql openssh pam pie postgres redis sqlite static"

RDEPEND="
	dev-vcs/git[curl,threads]
	memcached? ( net-misc/memcached )
	mysql? ( virtual/mysql )
	openssh? ( net-misc/openssh )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql )
	redis? ( dev-db/redis )
	sqlite? ( dev-db/sqlite )
"

FILECAPS=( cap_net_bind_service+ep usr/bin/gitea )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup git
	enewuser git -1 /bin/bash /var/lib/gitea git
}

# shellcheck disable=SC1117
src_prepare() {
	# Remove the git call, as the tarball isn't a proper git repository
	sed -i "/GITEA_VERSION :=/d" Makefile || die

	sed -i "s|^\(ROOT_PATH =\).*|\1 ${EPREFIX}/var/log/gitea|" \
		custom/conf/app.ini.sample || die

	if ! use bindata; then
		sed -i "s|^\(STATIC_ROOT_PATH =\).*|\1 ${EPREFIX}/usr/share/gitea|" \
			custom/conf/app.ini.sample || die
	fi

	default
}

src_compile() {
	local PATH="${G}/bin:$PATH"
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && ! use pie) && export CGO_ENABLED=0
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	# Build go-bindata locally
	go install ./vendor/github.com/kevinburke/go-bindata/go-bindata || die

	# Generate embedded data
	emake generate

	# Build up optional flags
	local opts=""
	use bindata && opts+=" bindata"
	use pam && opts+=" pam"
	use sqlite && opts+=" sqlite"
	use static && opts+=" netgo"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.Version=${PV/_/-}"
		-X "'main.Tags=${opts/ /}'"
	)
	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "${opts/ /}"
		-installsuffix "$(usex static 'netgo' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -tags='sqlite sqlite_unlock_notify' \
		$(go list ./... | grep -v /integrations) || die
}

src_install() {
	dobin gitea
	use debug && dostrip -x /usr/bin/gitea

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /var/lib/gitea/conf
	newins custom/conf/app.ini.sample app.ini.example

	if ! use bindata; then
		insinto /var/lib/gitea/custom
		doins -r options

		dosym ../custom/options/locale /var/lib/gitea/conf/locale

		insinto /usr/share/gitea
		doins -r public templates
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts -o git -g git -m 0750
	keepdir /var/log/gitea
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ ! -e "${EROOT}/var/lib/gitea/conf/app.ini" ]]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT}"/var/lib/gitea/conf/app.ini{.example,} || die
	else
		elog "app.ini found, please check example file for possible changes"
	fi

	if ! use filecaps; then
		ewarn
		ewarn "USE=filecaps is disabled, ${PN} will fail to listen on port < 1024"
		ewarn "please either change port to > 1024 or re-enable 'filecaps'"
		ewarn
	fi
}
