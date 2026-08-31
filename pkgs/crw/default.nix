{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

# Firecrawl-compatible scrape/crawl/search API, used as Open WebUI's web loader
# (WEB_LOADER_ENGINE=firecrawl). This fork replaces upstream's SearXNG sidecar
# with browser-driven search through Camoufox; only the scrape surface is used
# here, so `/v1/search` stays unconfigured.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "crw";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "adambenhassen";
    repo = "crw-camofox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XzncGL0GpvvKnUFT8BAbqTOkvO3ggU3Noq+z2SSuqu4=";
  };

  cargoHash = "sha256-oV655qeu0mCg+H0GfJiJJ+n5j5gujPFTNHHyezVR3K0=";

  # crw-server ships no default features; `camofox` pulls in `cdp` transitively.
  buildFeatures = [ "camofox" ];
  cargoBuildFlags = [
    "-p"
    "crw-server"
  ];

  # The suite drives real browsers and reaches the network.
  doCheck = false;

  meta = {
    description = "Rust web scraper, crawler and search API with a Firecrawl-compatible surface";
    homepage = "https://github.com/adambenhassen/crw-camofox";
    license = lib.licenses.agpl3Only;
    mainProgram = "crw-server";
    platforms = lib.platforms.linux;
  };
})
