#!/bin/sh
# Build the GitHub Pages preview and publish it to the gh-pages branch.
# Live at https://<owner>.github.io/<repo>/, where <owner>/<repo> is origin.
# Usage: sh scripts/deploy-pages.sh
set -eu

cd "$(dirname "$0")/.."
remote=$(git remote get-url origin)
owner=$(echo "$remote" | sed -E 's#^.*github\.com[:/]([^/]+)/.*$#\1#')
repo=$(basename "$remote" .git)
SITE_URL=https://$owner.github.io BASE_PATH=/$repo npx astro build

# Keep the preview out of search engines (pages also carry noindex)
printf 'User-agent: *\nDisallow: /\n' > dist/robots.txt

# _astro/ starts with an underscore, so Jekyll must be switched off
touch dist/.nojekyll

rev=$(git rev-parse --short HEAD)
tmp=$(mktemp -d)
cp -R dist/. "$tmp"
cd "$tmp"
git init -q -b gh-pages
git add -A
git commit -q -m "Deploy preview from $rev"
git push -q --force "$remote" gh-pages
cd - >/dev/null
rm -rf "$tmp"
echo "Deployed $rev to gh-pages"
