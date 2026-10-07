{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  git,
}:

# Non-interactive hunk surgery for agents: `git add -p` and `git checkout -p`
# drive themselves through a TTY prompt, which an agent cannot answer, so the
# usual fallback is staging whole files (or `git checkout --` over real work).
# git-surgeon addresses hunks by content-derived id instead.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-surgeon";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "git-surgeon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SeXHYZwhwvkYxFHW694Cp1VKKeehxgOdfKqShuPI7M4=";
  };

  cargoHash = "sha256-PbhASsdDxmVcIzV+oHIbpX70zjSeNvkwGcbhQRi88rE=";

  nativeBuildInputs = [ makeWrapper ];

  # Every subcommand shells out to git, and the binary also phones GitHub once a
  # day to advertise its own `update` subcommand — which would try to overwrite a
  # read-only store path.
  postInstall = ''
    wrapProgram $out/bin/git-surgeon \
      --prefix PATH : ${lib.makeBinPath [ git ]} \
      --set-default GIT_SURGEON_NO_UPDATE_CHECK 1
  '';

  meta = {
    description = "Git primitives for autonomous coding agents: hunk-level staging, commit splitting, folding";
    homepage = "https://github.com/raine/git-surgeon";
    changelog = "https://github.com/raine/git-surgeon/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "git-surgeon";
    platforms = lib.platforms.unix;
  };
})
