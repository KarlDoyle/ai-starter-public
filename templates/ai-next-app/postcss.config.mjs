/**
 * Tailwind 4 is CSS-first: the whole config lives in `src/app/globals.css`
 * (`@import "tailwindcss"` + `@theme`), so this file only wires the PostCSS
 * plugin. Autoprefixer is gone — Tailwind 4 prefixes what it emits itself.
 */
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
