# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep the following repos
# in sync with vendor/manifest:
# github.com/golang/crypto
# github.com/golang/net

CADDY_PLUGINS=(
	"AUTHZ1 github.com/casbin/caddy-authz e0ddc63" # Apache-2.0 license
	"AUTHZ2 github.com/casbin/casbin 24e6518" #v1.0.0 Apache-2.0 license
	"AUTHZ3 github.com/Knetic/govaluate aa73cfd" # MIT license

	"AWSES1 github.com/miquella/caddy-awses d364e01" # Apache-2.0 license
	"AWSES2 github.com/aws/aws-sdk-go 7607418" #v1.12.7 Apache-2.0 license

	"AWSLAMBDA github.com/coopernurse/caddy-awslambda 4ba23d3" # MIT license

	"CACHE1 github.com/nicolasazrak/caddy-cache a00a842" #v0.2.4 LGPL-3.0 license
	"CACHE2 github.com/pquerna/cachecontrol 525d0eb" # Apache-2.0 license

	"CGI github.com/jung-kurt/caddy-cgi f81f187" #v1.6 MIT license
	"CORS github.com/captncraig/cors a2bd860" # ??? license

	"DATADOG1 github.com/payintech/caddy-datadog 9e39028" #v18.04 MIT license
	"DATADOG2 github.com/DataDog/datadog-go e67964b" #v2.1.0 MIT license

	"EXPIRES github.com/epicagency/caddy-expires bb78f30" # MIT license
	"FILTER github.com/echocat/caddy-filter 70ca06d" #v0.11 MIT license
	"FWDPROXY github.com/caddyserver/forwardproxy 6c88222" # Apache-2.0 license
	"GIT github.com/abiosoft/caddy-git 3ea4951" # MIT license

	"GRPC1 github.com/pieterlouw/caddy-grpc d3d4d7c" #v0.0.4 Apache-2.0 license
	"GRPC2 github.com/mwitkow/grpc-proxy 67591eb" # Apache-2.0 license
	"GRPC3 github.com/improbable-eng/grpc-web 9cca7d4" #v0.5.0 Apache-2.0 license
	"GRPC4 github.com/rs/cors feef513" #v1.3.0 MIT license
	"GRPC5 github.com/grpc/grpc-go d11072e" #v1.11.3 Apache-2.0 license
	"GRPC6 github.com/google/go-genproto 73cb5d0" # Apache-2.0 license
	"GRPC7 github.com/golang/net f5079bd" # BSD license

	"IPFILTER1 github.com/pyed/ipfilter 6b25e48" # Apache-2.0 license
	"IPFILTER2 github.com/oschwald/maxminddb-golang d19f6d4" #1.2.0 ISC license

	"JWT1 github.com/BTBurke/caddy-jwt cdd97b5" #v3.6.1 MIT license
	"JWT2 github.com/dgrijalva/jwt-go 06ea103" #v3.2.0 MIT license

	"LOCALE github.com/simia-tech/caddy-locale 0bde64a" # ??? license

	"LOGIN1 github.com/tarent/loginsrv bf6909d" #v1.2.4 MIT license
	"LOGIN2 github.com/abbot/go-http-auth 0ddd408" #v0.4.0 Apache-2.0 license
	"LOGIN3 github.com/tarent/lib-compose 69430f9" # MIT license
	"LOGIN4 github.com/tarent/logrus e87ac79" # MIT license
	"LOGIN5 github.com/golang/crypto 2faea14" # BSD license

	"MAILOUT1 github.com/SchumacherFM/mailout 4c599f4" #v1.1.2 Apache-2.0 license
	"MAILOUT2 github.com/juju/ratelimit 5b9ff86" # LGPL-3 license
	"MAILOUT3 github.com/go-gomail/gomail 81ebce5" #v2 MIT license

	"MINIFY1 github.com/hacdias/caddy-minify 45164d3" # Apache-2.0 license
	"MINIFY2 github.com/tdewolff/minify 2226721" #v2.3.4 MIT license
	"MINIFY3 github.com/tdewolff/parse 639f627" #v2.3.2 MIT license

	"MULTIPASS1 github.com/namsral/multipass 7312af9" # BSD license
	"MULTIPASS2 github.com/gorilla/csrf 8aae08f" # BSD license
	"MULTIPASS3 github.com/gorilla/securecookie e59506c" # BSD license
	"MULTIPASS4 github.com/pkg/errors 2b3a18b" # BSD-2 license

	"NOBOTS github.com/Xumeiquer/nobots 9114efc" #v0.1.0 MIT license

	"PROMETHEUS1 github.com/miekg/caddy-prometheus 9329aaa" # Apache-2.0 license
	"PROMETHEUS2 github.com/prometheus/client_golang 82f5ff1" # Apache-2.0 license
	"PROMETHEUS3 github.com/beorn7/perks 3a771d9" # MIT license
	"PROMETHEUS4 github.com/prometheus/client_model 99fa1f4" # Apache-2.0 license
	"PROMETHEUS5 github.com/prometheus/procfs 8b1c2da" # Apache-2.0 license
	"PROMETHEUS6 github.com/prometheus/common e5b036c" # Apache-2.0 license
	"PROMETHEUS7 github.com/matttproud/golang_protobuf_extensions c12348c" # Apache-2.0 license

	"PROXYPROTO1 github.com/mastercactapus/caddy-proxyprotocol 5af9834" # ??? license
	"PROXYPROTO2 github.com/armon/go-proxyproto 48572f1" # MIT license

	"RTLIMIT github.com/xuqingfeng/caddy-rate-limit 1035313" #v1.3.1 MIT license
	"REALIP github.com/captncraig/caddy-realip 5dd1f40" # MIT license
	"REAUTH github.com/freman/caddy-reauth 839f01f" #v1.0.6 MIT license

	"RESTIC1 github.com/restic/caddy 27c8005" #v0.2.0 BSD-2 license
	"RESTIC2 github.com/restic/rest-server 2209f14" #v0.9.7 BSD-2 license

	"TEST github.com/mcuadros/go-syslog 9cf13b7" #v2.2.1 MIT license

	"UPLOAD1 github.com/wmark/caddy.upload f7f8806" #v1.3.2 BSD license
	"UPLOAD2 github.com/wmark/go.abs 1ba06a1" # ??? license

	"WEBDAV1 github.com/hacdias/caddy-webdav ef12bfa" # MIT license
	"WEBDAV2 github.com/hacdias/webdav 3d06904" #v1.2.0 MIT license
)

# shellcheck disable=SC2206
for mod in "${CADDY_PLUGINS[@]}"; do
	mod=(${mod})
	readonly HTTP_"${mod[0]}"_EGO_PN="${mod[1]}" HTTP_"${mod[0]}"_COMMIT="${mod[2]}" \
		HTTP_"${mod[0]}"_URI=https://"${mod[1]}"/archive/"${mod[2]}".tar.gz \
		HTTP_"${mod[0]}"_P="${mod[1]//\//-}"-"${mod[2]}"
done

inherit fcaps golang-vcs-snapshot systemd user

EGO_PN="github.com/mholt/caddy"
DESCRIPTION="Fast, cross-platform HTTP/2 web server with automatic HTTPS"
HOMEPAGE="https://caddyserver.com"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	authz? (
		${HTTP_AUTHZ1_URI} -> ${HTTP_AUTHZ1_P}.tar.gz
		${HTTP_AUTHZ2_URI} -> ${HTTP_AUTHZ2_P}.tar.gz
		${HTTP_AUTHZ3_URI} -> ${HTTP_AUTHZ3_P}.tar.gz
	)
	awses? (
		${HTTP_AWSES1_URI} -> ${HTTP_AWSES1_P}.tar.gz
		${HTTP_AWSES2_URI} -> ${HTTP_AWSES2_P}.tar.gz
	)
	awslambda? (
		${HTTP_AWSLAMBDA_URI} -> ${HTTP_AWSLAMBDA_P}.tar.gz
		!awses? ( ${HTTP_AWSES2_URI} -> ${HTTP_AWSES2_P}.tar.gz )
	)
	cache? (
		${HTTP_CACHE1_URI} -> ${HTTP_CACHE1_P}.tar.gz
		${HTTP_CACHE2_URI} -> ${HTTP_CACHE2_P}.tar.gz
	)
	cgi? ( ${HTTP_CGI_URI} -> ${HTTP_CGI_P}.tar.gz )
	cors? ( ${HTTP_CORS_URI} -> ${HTTP_CORS_P}.tar.gz )
	datadog? (
		${HTTP_DATADOG1_URI} -> ${HTTP_DATADOG1_P}.tar.gz
		${HTTP_DATADOG2_URI} -> ${HTTP_DATADOG2_P}.tar.gz
	)
	expires? ( ${HTTP_EXPIRES_URI} -> ${HTTP_EXPIRES_P}.tar.gz )
	filter? ( ${HTTP_FILTER_URI} -> ${HTTP_FILTER_P}.tar.gz )
	forwardproxy? ( ${HTTP_FWDPROXY_URI} -> ${HTTP_FWDPROXY_P}.tar.gz )
	git? ( ${HTTP_GIT_URI} -> ${HTTP_GIT_P}.tar.gz )
	grpc? (
		${HTTP_GRPC1_URI} -> ${HTTP_GRPC1_P}.tar.gz
		${HTTP_GRPC2_URI} -> ${HTTP_GRPC2_P}.tar.gz
		${HTTP_GRPC3_URI} -> ${HTTP_GRPC3_P}.tar.gz
		${HTTP_GRPC4_URI} -> ${HTTP_GRPC4_P}.tar.gz
		${HTTP_GRPC5_URI} -> ${HTTP_GRPC5_P}.tar.gz
		${HTTP_GRPC6_URI} -> ${HTTP_GRPC6_P}.tar.gz
		${HTTP_GRPC7_URI} -> ${HTTP_GRPC7_P}.tar.gz
	)
	ipfilter? (
		${HTTP_IPFILTER1_URI} -> ${HTTP_IPFILTER1_P}.tar.gz
		${HTTP_IPFILTER2_URI} -> ${HTTP_IPFILTER2_P}.tar.gz
	)
	jwt? (
		${HTTP_JWT1_URI} -> ${HTTP_JWT1_P}.tar.gz
		${HTTP_JWT2_URI} -> ${HTTP_JWT2_P}.tar.gz
	)
	locale? ( ${HTTP_LOCALE_URI} -> ${HTTP_LOCALE_P}.tar.gz )
	login? (
		${HTTP_LOGIN1_URI} -> ${HTTP_LOGIN1_P}.tar.gz
		${HTTP_LOGIN2_URI} -> ${HTTP_LOGIN2_P}.tar.gz
		${HTTP_LOGIN3_URI} -> ${HTTP_LOGIN3_P}.tar.gz
		${HTTP_LOGIN4_URI} -> ${HTTP_LOGIN4_P}.tar.gz
		${HTTP_LOGIN5_URI} -> ${HTTP_LOGIN5_P}.tar.gz
	)
	mailout? (
		${HTTP_MAILOUT1_URI} -> ${HTTP_MAILOUT1_P}.tar.gz
		${HTTP_MAILOUT2_URI} -> ${HTTP_MAILOUT2_P}.tar.gz
		${HTTP_MAILOUT3_URI} -> ${HTTP_MAILOUT3_P}.tar.gz
		!login? ( ${HTTP_LOGIN5_URI} -> ${HTTP_LOGIN5_P}.tar.gz )
	)
	minify? (
		${HTTP_MINIFY1_URI} -> ${HTTP_MINIFY1_P}.tar.gz
		${HTTP_MINIFY2_URI} -> ${HTTP_MINIFY2_P}.tar.gz
		${HTTP_MINIFY3_URI} -> ${HTTP_MINIFY3_P}.tar.gz
	)
	multipass? (
		${HTTP_MULTIPASS1_URI} -> ${HTTP_MULTIPASS1_P}.tar.gz
		${HTTP_MULTIPASS2_URI} -> ${HTTP_MULTIPASS2_P}.tar.gz
		${HTTP_MULTIPASS3_URI} -> ${HTTP_MULTIPASS3_P}.tar.gz
		${HTTP_MULTIPASS4_URI} -> ${HTTP_MULTIPASS4_P}.tar.gz
		!mailout? ( ${HTTP_MAILOUT3_URI} -> ${HTTP_MAILOUT3_P}.tar.gz )
	)
	nobots? ( ${HTTP_NOBOTS_URI} -> ${HTTP_NOBOTS_P}.tar.gz )
	prometheus? (
		${HTTP_PROMETHEUS1_URI} -> ${HTTP_PROMETHEUS1_P}.tar.gz
		${HTTP_PROMETHEUS2_URI} -> ${HTTP_PROMETHEUS2_P}.tar.gz
		${HTTP_PROMETHEUS3_URI} -> ${HTTP_PROMETHEUS3_P}.tar.gz
		${HTTP_PROMETHEUS4_URI} -> ${HTTP_PROMETHEUS4_P}.tar.gz
		${HTTP_PROMETHEUS5_URI} -> ${HTTP_PROMETHEUS5_P}.tar.gz
		${HTTP_PROMETHEUS6_URI} -> ${HTTP_PROMETHEUS6_P}.tar.gz
		${HTTP_PROMETHEUS7_URI} -> ${HTTP_PROMETHEUS7_P}.tar.gz
	)
	proxyprotocol? (
		${HTTP_PROXYPROTO1_URI} -> ${HTTP_PROXYPROTO1_P}.tar.gz
		${HTTP_PROXYPROTO2_URI} -> ${HTTP_PROXYPROTO2_P}.tar.gz
	)
	ratelimit? ( ${HTTP_RTLIMIT_URI} -> ${HTTP_RTLIMIT_P}.tar.gz )
	realip? ( ${HTTP_REALIP_URI} -> ${HTTP_REALIP_P}.tar.gz )
	reauth? ( ${HTTP_REAUTH_URI} -> ${HTTP_REAUTH_P}.tar.gz )
	restic? (
		${HTTP_RESTIC1_URI} -> ${HTTP_RESTIC1_P}.tar.gz
		${HTTP_RESTIC2_URI} -> ${HTTP_RESTIC2_P}.tar.gz
	)
	test? (
		${HTTP_TEST_URI} -> ${HTTP_TEST_P}.tar.gz
		!grpc? ( ${HTTP_GRPC7_URI} -> ${HTTP_GRPC7_P}.tar.gz )
	)
	upload? (
		${HTTP_UPLOAD1_URI} -> ${HTTP_UPLOAD1_P}.tar.gz
		${HTTP_UPLOAD2_URI} -> ${HTTP_UPLOAD2_P}.tar.gz
		!multipass? ( ${HTTP_MULTIPASS4_URI} -> ${HTTP_MULTIPASS4_P}.tar.gz )
	)
	webdav? (
		${HTTP_WEBDAV1_URI} -> ${HTTP_WEBDAV1_P}.tar.gz
		${HTTP_WEBDAV2_URI} -> ${HTTP_WEBDAV2_P}.tar.gz
		!test? (
			!grpc? ( ${HTTP_GRPC7_URI} -> ${HTTP_GRPC7_P}.tar.gz )
		)
	)"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="authz awses awslambda cache cgi cors datadog expires
	filter forwardproxy git grpc ipfilter jwt locale login mailout
	minify multipass nobots prometheus proxyprotocol ratelimit realip
	reauth restic test upload webdav"
REQUIRED_USE="login? ( jwt )"

FILECAPS=( cap_net_bind_service+ep usr/sbin/caddy )

DOCS=( dist/CHANGES.txt README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"
CADDYMAIN="caddy/caddymain"

pkg_setup() {
	enewgroup caddy
	enewuser caddy -1 -1 -1 caddy
}

src_unpack() {
	use authz && EGO_VENDOR+=(
		"${HTTP_AUTHZ1_EGO_PN} ${HTTP_AUTHZ1_COMMIT}"
		"${HTTP_AUTHZ2_EGO_PN} ${HTTP_AUTHZ2_COMMIT}"
		"${HTTP_AUTHZ3_EGO_PN} ${HTTP_AUTHZ3_COMMIT}"
	)

	use awses && EGO_VENDOR+=(
		"${HTTP_AWSES1_EGO_PN} ${HTTP_AWSES1_COMMIT}"
		"${HTTP_AWSES2_EGO_PN} ${HTTP_AWSES2_COMMIT}"
	)

	if use awslambda; then
		EGO_VENDOR+=( "${HTTP_AWSLAMBDA_EGO_PN} ${HTTP_AWSLAMBDA_COMMIT}" )
		use awses || EGO_VENDOR+=(
			"${HTTP_AWSES2_EGO_PN} ${HTTP_AWSES2_COMMIT}"
		)
	fi

	use cache && EGO_VENDOR+=(
		"${HTTP_CACHE1_EGO_PN} ${HTTP_CACHE1_COMMIT}"
		"${HTTP_CACHE2_EGO_PN} ${HTTP_CACHE2_COMMIT}"
	)

	use cgi && EGO_VENDOR+=( "${HTTP_CGI_EGO_PN} ${HTTP_CGI_COMMIT}" )
	use cors && EGO_VENDOR+=( "${HTTP_CORS_EGO_PN} ${HTTP_CORS_COMMIT}" )

	use datadog && EGO_VENDOR+=(
		"${HTTP_DATADOG1_EGO_PN} ${HTTP_DATADOG1_COMMIT}"
		"${HTTP_DATADOG2_EGO_PN} ${HTTP_DATADOG2_COMMIT}"
	)

	use expires && EGO_VENDOR+=( "${HTTP_EXPIRES_EGO_PN} ${HTTP_EXPIRES_COMMIT}" )
	use filter && EGO_VENDOR+=( "${HTTP_FILTER_EGO_PN} ${HTTP_FILTER_COMMIT}" )
	use forwardproxy && EGO_VENDOR+=( "${HTTP_FWDPROXY_EGO_PN} ${HTTP_FWDPROXY_COMMIT}" )
	use git && EGO_VENDOR+=( "${HTTP_GIT_EGO_PN} ${HTTP_GIT_COMMIT}" )

	use grpc && EGO_VENDOR+=(
		"${HTTP_GRPC1_EGO_PN} ${HTTP_GRPC1_COMMIT}"
		"${HTTP_GRPC2_EGO_PN} ${HTTP_GRPC2_COMMIT}"
		"${HTTP_GRPC3_EGO_PN} ${HTTP_GRPC3_COMMIT}"
		"${HTTP_GRPC4_EGO_PN} ${HTTP_GRPC4_COMMIT}"
		"google.golang.org/grpc ${HTTP_GRPC5_COMMIT} ${HTTP_GRPC5_EGO_PN}"
		"google.golang.org/genproto ${HTTP_GRPC6_COMMIT} ${HTTP_GRPC6_EGO_PN}"
		"golang.org/x/net ${HTTP_GRPC7_COMMIT} ${HTTP_GRPC7_EGO_PN}"
	)

	use ipfilter && EGO_VENDOR+=(
		"${HTTP_IPFILTER1_EGO_PN} ${HTTP_IPFILTER1_COMMIT}"
		"${HTTP_IPFILTER2_EGO_PN} ${HTTP_IPFILTER2_COMMIT}"
	)

	use jwt && EGO_VENDOR+=(
		"${HTTP_JWT1_EGO_PN} ${HTTP_JWT1_COMMIT}"
		"${HTTP_JWT2_EGO_PN} ${HTTP_JWT2_COMMIT}"
	)

	use locale && EGO_VENDOR+=( "${HTTP_LOCALE_EGO_PN} ${HTTP_LOCALE_COMMIT}" )

	use login && EGO_VENDOR+=(
		"${HTTP_LOGIN1_EGO_PN} ${HTTP_LOGIN1_COMMIT}"
		"${HTTP_LOGIN2_EGO_PN} ${HTTP_LOGIN2_COMMIT}"
		"${HTTP_LOGIN3_EGO_PN} ${HTTP_LOGIN3_COMMIT}"
		"${HTTP_LOGIN4_EGO_PN} ${HTTP_LOGIN4_COMMIT}"
		"golang.org/x/crypto ${HTTP_LOGIN5_COMMIT} ${HTTP_LOGIN5_EGO_PN}"
	)

	if use mailout; then
		EGO_VENDOR+=(
			"${HTTP_MAILOUT1_EGO_PN} ${HTTP_MAILOUT1_COMMIT}"
			"${HTTP_MAILOUT2_EGO_PN} ${HTTP_MAILOUT2_COMMIT}"
			"gopkg.in/gomail.v2 ${HTTP_MAILOUT3_COMMIT} ${HTTP_MAILOUT3_EGO_PN}"
		)
		use login || EGO_VENDOR+=(
			"golang.org/x/crypto ${HTTP_LOGIN5_COMMIT} ${HTTP_LOGIN5_EGO_PN}"
		)
	fi

	use minify && EGO_VENDOR+=(
		"${HTTP_MINIFY1_EGO_PN} ${HTTP_MINIFY1_COMMIT}"
		"${HTTP_MINIFY2_EGO_PN} ${HTTP_MINIFY2_COMMIT}"
		"${HTTP_MINIFY3_EGO_PN} ${HTTP_MINIFY3_COMMIT}"
	)

	if use multipass; then
		EGO_VENDOR+=(
			"${HTTP_MULTIPASS1_EGO_PN} ${HTTP_MULTIPASS1_COMMIT}"
			"${HTTP_MULTIPASS2_EGO_PN} ${HTTP_MULTIPASS2_COMMIT}"
			"${HTTP_MULTIPASS3_EGO_PN} ${HTTP_MULTIPASS3_COMMIT}"
			"${HTTP_MULTIPASS4_EGO_PN} ${HTTP_MULTIPASS4_COMMIT}"
		)
		use mailout || EGO_VENDOR+=(
			"gopkg.in/gomail.v2 ${HTTP_MAILOUT3_COMMIT} ${HTTP_MAILOUT3_EGO_PN}"
		)
	fi

	use nobots && EGO_VENDOR+=( "${HTTP_NOBOTS_EGO_PN} ${HTTP_NOBOTS_COMMIT}" )

	use prometheus && EGO_VENDOR+=(
		"${HTTP_PROMETHEUS1_EGO_PN} ${HTTP_PROMETHEUS1_COMMIT}"
		"${HTTP_PROMETHEUS2_EGO_PN} ${HTTP_PROMETHEUS2_COMMIT}"
		"${HTTP_PROMETHEUS3_EGO_PN} ${HTTP_PROMETHEUS3_COMMIT}"
		"${HTTP_PROMETHEUS4_EGO_PN} ${HTTP_PROMETHEUS4_COMMIT}"
		"${HTTP_PROMETHEUS5_EGO_PN} ${HTTP_PROMETHEUS5_COMMIT}"
		"${HTTP_PROMETHEUS6_EGO_PN} ${HTTP_PROMETHEUS6_COMMIT}"
		"${HTTP_PROMETHEUS7_EGO_PN} ${HTTP_PROMETHEUS7_COMMIT}"
	)

	use proxyprotocol && EGO_VENDOR+=(
		"${HTTP_PROXYPROTO1_EGO_PN} ${HTTP_PROXYPROTO1_COMMIT}"
		"${HTTP_PROXYPROTO2_EGO_PN} ${HTTP_PROXYPROTO2_COMMIT}"
	)

	use ratelimit && EGO_VENDOR+=( "${HTTP_RTLIMIT_EGO_PN} ${HTTP_RTLIMIT_COMMIT}" )
	use realip && EGO_VENDOR+=( "${HTTP_REALIP_EGO_PN} ${HTTP_REALIP_COMMIT}" )
	use reauth && EGO_VENDOR+=( "${HTTP_REAUTH_EGO_PN} ${HTTP_REAUTH_COMMIT}" )

	use restic && EGO_VENDOR+=(
		"${HTTP_RESTIC1_EGO_PN} ${HTTP_RESTIC1_COMMIT}"
		"${HTTP_RESTIC2_EGO_PN} ${HTTP_RESTIC2_COMMIT}"
	)

	if use test; then
		EGO_VENDOR+=( "gopkg.in/mcuadros/go-syslog.v2 ${HTTP_TEST_COMMIT} ${HTTP_TEST_EGO_PN}" )
		use grpc || EGO_VENDOR+=(
			"golang.org/x/net ${HTTP_GRPC7_COMMIT} ${HTTP_GRPC7_EGO_PN}"
		)
	fi

	if use upload; then
		EGO_VENDOR+=(
			"blitznote.com/src/caddy.upload ${HTTP_UPLOAD1_COMMIT} ${HTTP_UPLOAD1_EGO_PN}"
			"plugin.hosting/go/abs ${HTTP_UPLOAD2_COMMIT} ${HTTP_UPLOAD2_EGO_PN}"
		)
		use multipass || EGO_VENDOR+=(
			"${HTTP_MULTIPASS4_EGO_PN} ${HTTP_MULTIPASS4_COMMIT}"
		)
	fi

	if use webdav; then
		EGO_VENDOR+=(
			"${HTTP_WEBDAV1_EGO_PN} ${HTTP_WEBDAV1_COMMIT}"
			"${HTTP_WEBDAV2_EGO_PN} ${HTTP_WEBDAV2_COMMIT}"
		)
		if ! use test; then
			use grpc || EGO_VENDOR+=(
				"golang.org/x/net ${HTTP_GRPC7_COMMIT} ${HTTP_GRPC7_EGO_PN}"
			)
		fi
	fi

	golang-vcs-snapshot_src_unpack
}

src_prepare() {
	if use authz; then
		sed -i "/(imported)/a _ \"$HTTP_AUTHZ1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use awses; then
		sed -i "/(imported)/a _ \"$HTTP_AWSES1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use awslambda; then
		sed -i "/(imported)/a _ \"$HTTP_AWSLAMBDA_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use cache; then
		sed -i "/(imported)/a _ \"$HTTP_CACHE1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use cgi; then
		sed -i "/(imported)/a _ \"$HTTP_CGI_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use cors; then
		sed -i "/(imported)/a _ \"$HTTP_CORS_EGO_PN/caddy\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use datadog; then
		sed -i "/(imported)/a _ \"$HTTP_DATADOG1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use expires; then
		sed -i "/(imported)/a _ \"$HTTP_EXPIRES_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use filter; then
		sed -i "/(imported)/a _ \"$HTTP_FILTER_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use forwardproxy; then
		sed -i "/(imported)/a _ \"$HTTP_FWDPROXY_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use git; then
		sed -i "/(imported)/a _ \"$HTTP_GIT_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use grpc; then
		sed -i "/(imported)/a _ \"$HTTP_GRPC1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use ipfilter; then
		sed -i "/(imported)/a _ \"$HTTP_IPFILTER1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use jwt; then
		sed -i "/(imported)/a _ \"$HTTP_JWT1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use locale; then
		sed -i "/(imported)/a _ \"$HTTP_LOCALE_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use login; then
		sed -i "/(imported)/a _ \"$HTTP_LOGIN1_EGO_PN/caddy\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use mailout; then
		sed -i "/(imported)/a _ \"$HTTP_MAILOUT1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use minify; then
		sed -i "/(imported)/a _ \"$HTTP_MINIFY1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use multipass; then
		sed -i "/(imported)/a _ \"$HTTP_MULTIPASS1_EGO_PN/caddy\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use nobots; then
		sed -i "/(imported)/a _ \"$HTTP_NOBOTS_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use prometheus; then
		sed -i "/(imported)/a _ \"$HTTP_PROMETHEUS1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use proxyprotocol; then
		sed -i "/(imported)/a _ \"$HTTP_PROXYPROTO1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use realip; then
		sed -i "/(imported)/a _ \"$HTTP_REALIP_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use ratelimit; then
		sed -i "/(imported)/a _ \"$HTTP_RTLIMIT_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use reauth; then
		sed -i "/(imported)/a _ \"$HTTP_REAUTH_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use restic; then
		sed -i "/(imported)/a _ \"$HTTP_RESTIC1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	if use upload; then
		sed -i '/(imported)/a _ "blitznote.com/src/caddy.upload"' \
			${CADDYMAIN}/run.go || die
	fi

	if use webdav; then
		sed -i "/(imported)/a _ \"$HTTP_WEBDAV1_EGO_PN\"" \
			${CADDYMAIN}/run.go || die
	fi

	default
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w
		-X ${EGO_PN}/${CADDYMAIN}.gitTag=${PV}"

	go install -v -ldflags \
		"${GOLDFLAGS}" ./caddy || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dosbin "${G}"/bin/caddy
	einstalldocs

	newinitd "${FILESDIR}"/caddy.initd caddy
	newconfd "${FILESDIR}"/caddy.confd caddy
	systemd_newunit "${FILESDIR}"/caddy.service-r1 caddy.service

	insinto /etc/caddy
	doins "${FILESDIR}"/Caddyfile.example

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/caddy.logrotate caddy

	diropts -o caddy -g caddy -m 0750
	keepdir /etc/caddy/cert /var/log/caddy
}

pkg_postinst() {
	# Caddy currently does not support dropping privileges so we
	# change attributes with setcap to allow access to priv ports
	# https://github.com/mholt/caddy/issues/528
	fcaps_pkg_postinst

	if ! use filecaps; then
		ewarn
		ewarn "'filecaps' USE flag is disabled"
		ewarn "${PN} will fail to listen on port 80/443 if started via OpenRC"
		ewarn "please either change port to > 1024 or re-enable 'filecaps'"
		ewarn
	fi
}
