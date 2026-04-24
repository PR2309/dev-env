NPM_VERSION=$(cat npm/npm-version.txt)
npm install -g npm@"$NPM_VERSION"
echo "NPM version $NPM_VERSION installed successfully"