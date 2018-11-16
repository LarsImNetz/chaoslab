# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://raw.githubusercontent.com/ImageOptim/gifski/0.8.5/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
ansi_term-0.11.0
arrayvec-0.4.7
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
bitflags-1.0.4
cc-1.0.23
cfg-if-0.1.5
clap-2.32.0
color_quant-1.0.1
crossbeam-deque-0.2.0
crossbeam-epoch-0.3.1
crossbeam-utils-0.2.2
either-1.5.0
error-chain-0.12.0
gif-0.10.0
gif-dispose-2.1.1
glob-0.2.11
imagequant-2.11.9
imagequant-sys-2.12.0
imgref-1.3.5
kernel32-sys-0.2.2
lazy_static-1.1.0
libc-0.2.43
lodepng-2.4.1
lzw-0.10.0
memoffset-0.2.1
natord-1.0.9
nodrop-0.1.12
num_cpus-1.8.0
openmp-sys-0.1.6
pbr-1.0.1
rayon-1.0.2
rayon-core-1.4.1
redox_syscall-0.1.40
redox_termios-0.1.1
resize-0.3.0
rgb-0.8.11
rustc-demangle-0.1.9
scopeguard-0.3.3
strsim-0.7.0
termion-1.5.1
textwrap-0.10.0
time-0.1.40
unicode-width-0.1.5
vec_map-0.8.1
version_check-0.1.4
wild-2.0.0
winapi-0.2.8
winapi-0.3.5
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="GIF encoder based on libimagequant"
HOMEPAGE="https://gif.ski"
# shellcheck disable=SC2086
SRC_URI="https://github.com/ImageOptim/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openmp"

RDEPEND="media-gfx/libimagequant[openmp?]"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${P}-remove_video.patch" )

src_compile() {
	# shellcheck disable=SC2153
	export CARGO_HOME="${ECARGO_HOME}"

	cargo build -v "$(usex debug '' --release)" \
		"$(usex openmp '--features=openmp' '')" || die
}

src_install() {
	dobin target/release/gifski
}
