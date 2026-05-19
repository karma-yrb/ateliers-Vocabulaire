const htmlVersionUpdater = {
  readVersion(contents) {
    const match = contents.match(/data-app-version="([^"]+)"/);
    return match ? match[1] : null;
  },
  writeVersion(contents, version) {
    let updated = contents.replace(/data-app-version="[^"]+"/, `data-app-version="${version}"`);
    updated = updated.replace(
      /(<span id="app-version"[^>]*>)([^<]*)(<\/span>)/,
      `$1${version}$3`
    );
    return updated;
  },
};

module.exports = {
  packageFiles: [
    "package.json",
  ],
  bumpFiles: [
    {
      filename: "package.json",
      type: "json",
    },
    {
      filename: "index.html",
      updater: htmlVersionUpdater,
    },
  ],
};
