# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit autotools bash-completion-r1 python-any-r1

DESCRIPTION="Tools for the TPM 2.0 TSS"
HOMEPAGE="https://github.com/tpm2-software/tpm2-tools"
SRC_URI="https://github.com/tpm2-software/tpm2-tools/releases/download/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 arm arm64 ppc64 x86"
IUSE="+fapi test"

RESTRICT="!test? ( test )"

RDEPEND=">=app-crypt/tpm2-tss-3.0.1:=[fapi?]
	dev-libs/openssl:=
	net-misc/curl
	sys-libs/efivar:="
DEPEND="${RDEPEND}
	test? (
		app-crypt/swtpm
		app-crypt/tpm2-abrmd
		dev-util/cmocka
	)"
BDEPEND="virtual/pkgconfig
	sys-devel/autoconf-archive
	test? (
		app-editors/vim-core
		dev-tcltk/expect
		$(python_gen_any_dep 'dev-python/pyyaml[${PYTHON_USEDEP}]')
	)
	${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}/${PN}-5.1.1-no-efivar-automagic.patch"
	"${FILESDIR}/${PN}-5.2-testparms-fix-condition-for-negative-test.patch"
)

src_prepare() {
	default
	sed -i \
	"s/m4_esyscmd_s(\[git describe --tags --always --dirty\])/${PV}/" \
		"configure.ac" || die
	"./scripts/utils/man_to_bashcompletion.sh" || die
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable fapi) \
		$(use_enable test unit) \
		--with-bashcompdir=$(get_bashcompdir) \
		--enable-hardening
}

src_install() {
	default
	mv "${ED}"/$(get_bashcompdir)/tpm2{_completion.bash,} || die
	local utils=( "${ED}"/usr/bin/tpm2_* )
	bashcomp_alias tpm2 "${utils[@]##*/}"
}
