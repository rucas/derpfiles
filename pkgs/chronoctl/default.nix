{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "chronoctl";
  version = "1.36.0";

  src = fetchFromGitHub {
    owner = "chronosphereio";
    repo = "chronoctl-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9pM4yQy1135oqAd+IYtADlmJovybiDztV88BxTeKhzg=";
  };

  vendorHash = "sha256-ELJCBFfcmVy5HmzKxHsqpqpJODJtLJkEV/z3xkjGWq4=";

  subPackages = [ "src/cmd/chronoctl" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/chronosphereio/chronoctl-core/src/cmd/pkg/buildinfo.Version=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd chronoctl \
      --bash <($out/bin/chronoctl completion bash) \
      --fish <($out/bin/chronoctl completion fish) \
      --zsh <($out/bin/chronoctl completion zsh)
  '';

  meta = {
    description = "CLI for managing Chronosphere observability platform resources";
    homepage = "https://docs.chronosphere.io/tooling/chronoctl";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "chronoctl";
  };
})
