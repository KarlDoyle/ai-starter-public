// Allow side-effect imports of global stylesheets (e.g. `import "./globals.css"`)
// under `tsc --noEmit`. Next handles the actual bundling; Next's own types only
// declare CSS *modules* (`*.module.css`), so plain global CSS needs this ambient
// declaration for the typecheck gate to pass. `*.module.css` stays more specific,
// so CSS-module typing is unaffected.
declare module "*.css";
