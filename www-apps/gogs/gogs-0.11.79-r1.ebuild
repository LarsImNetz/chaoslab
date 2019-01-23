# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="f43d21d0aff791780aaca5770e0bc92c39c803d3"
EGO_VENDOR=( "github.com/kevinburke/go-bindata v3.13.0" )
EGO_PN="github.com/${PN}/${PN}"

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A painless self-hosted Git service"
HOMEPAGE="https://gogs.io"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug cert memcached mysql openssh pam pie postgres redis sqlite static"

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

FILECAPS=( cap_net_bind_service+ep usr/bin/gogs )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup gogs
	enewuser gogs -1 /bin/bash /var/lib/gogs gogs
}

src_prepare() {
	# shellcheck disable=SC1117
	sed -i \
		-e "s|^\(RUN_USER =\).*|\1 gogs|" \
		-e "s|^\(STATIC_ROOT_PATH =\).*|\1 ${EPREFIX}/usr/share/gogs|" \
		-e "s|^\(ROOT_PATH =\).*|\1 ${EPREFIX}/var/log/gogs|" \
		conf/app.ini || die

	# Remove bundled binary, we will rebuild it ourselves
	rm pkg/bindata/bindata.go || die

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
	go-bindata \
		-o=pkg/bindata/bindata.go \
		-ignore="\\.DS_Store|README.md|TRANSLATORS|auth.d" \
		-pkg=bindata conf/... || die

	# Build up optional flags
	local opts=""
	use cert && opts+=" cert"
	use pam && opts+=" pam"
	use sqlite && opts+=" sqlite"
	use static && opts+=" netgo"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "'${EGO_PN}/pkg/setting.BuildTime=$(date -u '+%Y-%m-%d %I:%M:%S %Z')'"
		-X "${EGO_PN}/pkg/setting.BuildGitHash=${GIT_COMMIT}"
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
	go test -v -cover -race ./... || die
}

src_install() {
	dobin gogs
	use debug && dostrip -x /usr/bin/gogs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /var/lib/gogs/conf
	newins conf/app.ini app.ini.example

	insinto /usr/share/gogs
	doins -r templates

	insinto /usr/share/gogs/public
	doins -r public/{assets,css,img,js,plugins}

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate-r1" "${PN}"

	diropts -o gogs -g gogs -m 0750
	keepdir /var/log/gogs
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ ! -e "${EROOT}/var/lib/gogs/conf/app.ini" ]]; then
		elog "No app.ini found, copying the example over"
		cp "${EROOT}"/var/lib/gogs/conf/app.ini{.example,} || die
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
